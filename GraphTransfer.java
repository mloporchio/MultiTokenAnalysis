import java.math.BigInteger;
import java.util.Objects;

/**
 * Utility class representing a generic transfer.
 * Each token transfer is associated with the following information:
 * 1) numeric identifier of the sender;
 * 2) numeric identifier of the recipient;
 * 3) identifier of the token being exchanged;
 * 4) amount of tokens being transferred.
 * 
 * @author Matteo Loporchio
 */
public class GraphTransfer implements Comparable<GraphTransfer> {
	public final int fromId;
	public final int toId;
	public final String tokenId;
	public final BigInteger value;

	public GraphTransfer(int fromId, int toId, String tokenId, BigInteger value) {
		this.fromId = fromId;
		this.toId = toId;
		this.tokenId = tokenId;
		this.value = value;
	}

    @Override
    public int hashCode() {
        return Objects.hash(this.fromId, this.toId);
    }
    
    @Override
    public boolean equals(Object o) {
        if (!(o instanceof GraphTransfer)) return false;
        if (o == this) return true;
        GraphTransfer e = (GraphTransfer) o;
        return (this.fromId == e.fromId && this.toId == e.toId);
    }

	@Override
	public int compareTo(GraphTransfer o) {
		int s = Integer.compare(this.fromId, o.fromId);
		return ((s != 0) ? s : Integer.compare(this.toId, o.toId));
	}
}