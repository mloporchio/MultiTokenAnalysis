import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.math.BigInteger;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * This class constructs a weighted graph from a list of ERC-1155 transfers.
 * The graph is defined as follows:
 * 	- each node represents an Ethereum addresses;
 * 	- each directed edge (u, v) describes a transfer from address u to address v.
 * 	- each edge (u, v) is labeled with the following information:
 * 		1) The total number of transfers from u to v.
 * 		2) The number of unique tokens transferred from u to v.
 * 		3) The total amount of tokens transferred from u to v.
 * 
 * Notice that:
 *  - mint and burn operations, as well as self-transfers, are ignored during graph construction;
 *  - addresses in the original transfer list are mapped to consecutive integers in the range [0, N-1] to represent N graph nodes.
 * 
 * INPUT:
 * A CSV file containing a list of ERC-1155 transfers for a given contract.
 * Each row includes the following fields.
 * 1) Block identifier in which the transfer occurred.
 * 2) Numeric identifier of the contract that produced the event.
 * 3) Numeric identifier of the sender of the transfer.
 * 4) Numeric identifier of the recipient of the transfer.
 * 5) Numeric identifier of the token being transferred.
 * 6) Amount of tokens transferred.
 * 
 * OUTPUT:
 * Two TSV files representing:
 * 1) The weighted list of edges. Each row has the following format.
 * 		- numeric identifier of sender;
 * 		- numeric identifier of receiver;
 * 		- total number of transfers from sender to receiver;
 * 		- number of unique tokens transferred from sender to receiver;
 * 		- total amount of tokens transferred from sender to receiver.
 * 2) The mapping between original address identifiers (as used in the input file) and node identifiers (used in the edge list).
 * 
 * PRINT:
 * 1) Number of nodes in the graph.
 * 2) Number of edges in the graph.
 * 3) Elapsed time for construction.
 *  
 * @author Matteo Loporchio
 */
public class GraphBuilder {
	public static int nextId = 0;
	public static Map<Integer, Integer> nodes = new LinkedHashMap<>();
	public static List<GraphTransfer> edges = new ArrayList<>();
    
    public static void main(String[] args) {
		if (args.length < 3) {
			System.err.printf("Usage: java %s <inputFile> <edgeListFile> <nodeMapFile>\n", GraphBuilder.class.getName());
			System.exit(1);
		}

		// Read all input parameters.
        final String inputFile = args[0];
		final String edgeListFile = args[1];
		final String nodeMapFile = args[2];
        
		long start = System.nanoTime();
        try (
				BufferedReader in = new BufferedReader(new InputStreamReader(new FileInputStream(inputFile)));
				PrintWriter edgeOut = new PrintWriter(edgeListFile);
				PrintWriter nodeOut = new PrintWriter(nodeMapFile);
		) {
			String line = null;
			while ((line = in.readLine()) != null) {
				String[] parts = line.split(",");
				// The line includes the following fields.
				// * 0) Block identifier in which the transfer occurred.
				// * 1) Numeric identifier of the contract that produced the event.
				// * 2) Numeric identifier of the sender of the transfer.
				// * 3) Numeric identifier of the recipient of the transfer.
				// * 4) Numeric identifier of transferred token.
				// * 5) Amount of tokens transferred.
				int fromAddress = Integer.parseInt(parts[2]);
				int toAddress = Integer.parseInt(parts[3]);
				// Transfers with sender = 0x0 (mint) or receiver = 0x0 (burn) are ignored, as well as self-loops.
				if (fromAddress != 0 && toAddress != 0 && fromAddress != toAddress)  {
					int fromId = getOrCreateId(fromAddress);
					int toId = getOrCreateId(toAddress);
					String tokenId = parts[4];
                    BigInteger amount = new BigInteger(parts[5]);
					edges.add(new GraphTransfer(fromId, toId, tokenId, amount));
				}
			}
			// Sort the list of edges according to the (fromId, toId) fields.
			Collections.sort(edges);
			// Write the list of edges to the output file.
			int numUniqueEdges = 0;
			if (edges.size() > 0) {
				GraphTransfer prev = edges.get(0);
				int count = 1;
				BigInteger totalValue = prev.value;
				Set<String> tokenIds = new HashSet<>();
				tokenIds.add(prev.tokenId);
				for (int i = 1; i < edges.size(); i++) {
					GraphTransfer curr = edges.get(i);
					if (curr.equals(prev)) {
						count++;
						totalValue = totalValue.add(curr.value);
						tokenIds.add(curr.tokenId);
					} 
					else {
						edgeOut.printf("%d\t%d\t%d\t%d\t%s\n", 
						prev.fromId, prev.toId, count, tokenIds.size(), totalValue.toString());
						numUniqueEdges++;
						prev = curr;
						count = 1;
						totalValue = curr.value;
						tokenIds.clear();
						tokenIds.add(curr.tokenId);
					}
				}
				edgeOut.printf("%d\t%d\t%d\t%d\t%s\n", 
				prev.fromId, prev.toId, count, tokenIds.size(), totalValue.toString());
				numUniqueEdges++;
			}
			// Write the (address, id) associations to the corresponding file.
			for (int key : nodes.keySet()) nodeOut.printf("%d\t%d\n", key, nodes.get(key));
			// Stampa in output il numero di nodi, archi e tempo impiegato per la costruzione.
			long end = System.nanoTime();
			System.out.printf("%d\t%d\t%d\n", nodes.size(), numUniqueEdges, end-start);
		}
		catch (Exception e) {
			e.printStackTrace();
			System.exit(1);
		}
    }

	/**
	 * Assigns a unique and progressive numeric identifier to an address.
	 * @param address the input address
	 * @return an identifier for the current address
	 */
	public static int getOrCreateId(int address) {
		Integer id = nodes.get(address);
		if (id == null) {
			id = nextId;
			nodes.put(address, id);
			nextId++;
		}
		return id;
	}

}