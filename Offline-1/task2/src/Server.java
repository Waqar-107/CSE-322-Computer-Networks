import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;

public class Server {

    public static final int port = 8080;
    public static int cntClient;

    public static void main(String[] args) throws IOException {
        ServerSocket serverSocket = new ServerSocket(port);
        System.out.println("server started");

        cntClient = 0;

        while (true)
        {
            Socket socket = serverSocket.accept();
            cntClient++;

            new Thread(new ClientThread(socket,cntClient)).start();
        }
    }
}
