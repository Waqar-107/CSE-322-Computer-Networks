import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;

public class Server {

    public static final int port=8080;

    public static void main(String[] args) throws IOException
    {
        ServerSocket serverSocket=new ServerSocket(port);
        System.out.println("server started");

        while(true)
        {
            Socket socket=serverSocket.accept();
            new Thread(new ClientThread(socket)).start();
        }
    }
}
