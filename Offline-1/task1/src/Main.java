import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.InetAddress;
import java.net.Socket;

public class Main {

    private static Socket smtpSocket;
    private static BufferedReader br;
    private static PrintWriter pr;
    private static BufferedReader in;
    private static String receive, input;


    //------------------------------------------------------------------------------------
    public static void closing() throws IOException {
        System.out.println("\nclosing down everything");

        br.close();
        pr.close();
        smtpSocket.close();

        System.exit(1);
    }
    //------------------------------------------------------------------------------------


    //------------------------------------------------------------------------------------
    public static void sendCommand() throws IOException {
        while (true) {

            System.out.println("enter command to send to the smtp server-");
            input = in.readLine();

            pr.println(input);
            receive = br.readLine();
            System.out.println("message from server: " + receive + "\n");

            if (!receive.startsWith("250") && !receive.startsWith("354"))
                closing();

            if (input.equalsIgnoreCase("data")) {
                sendData();

                pr.println(".");
                receive=br.readLine();
                System.out.println("message from server: " + receive + "\n");
            }

            else if (input.equalsIgnoreCase("quit"))
                closing();

        }
    }
    //------------------------------------------------------------------------------------


    //------------------------------------------------------------------------------------
    public static void sendData() throws IOException {
        System.out.println("entered in data input portion, writing a single '.' in a line will indicate end of your mail.");
        System.out.println("enter subject, from, to, then an empty line and your message");

        while (true) {
            input = in.readLine();

            if(input.length()==0){
                //System.out.println("the emp");
                pr.println();
                continue;
            }

            if(input.equals(".")) {
                return;
            }

            else
                pr.println(input+"\r\n");
        }

    }
    //------------------------------------------------------------------------------------


    //------------------------------------------------------------------------------------
    public static void main(String[] args) throws IOException {
        String mailServerAddress = "smtp.sendgrid.net";

        InetAddress mailHost = InetAddress.getByName(mailServerAddress);
        InetAddress localHost = InetAddress.getLocalHost();

        smtpSocket = new Socket(mailHost, 587);

        br = new BufferedReader(new InputStreamReader(smtpSocket.getInputStream()));
        pr = new PrintWriter(smtpSocket.getOutputStream(),true);

        in = new BufferedReader(new InputStreamReader(System.in));

        //----------------------------------------------------------------
        //after connecting smtp server shall send 220 and some strings concatenated with it
        receive = br.readLine();

        if (receive.startsWith("220"))
            System.out.println("connected. message from server : " + receive + "\n");
        else {
            System.out.println("error!!! message from server" + receive + "\n");
            closing();
        }
        //----------------------------------------------------------------

        //----------------------------------------------------------------
        //authenticate using username and api-key for authorization of sending mail
        pr.println("AUTH LOGIN");
        receive = br.readLine();

        System.out.println("requested for authentication .message from server : " + receive);
        if (!receive.equals("334 VXNlcm5hbWU6"))
            closing();


        //send your username - base64 encoding of "apikey"
        pr.println("YXBpa2V5");
        receive = br.readLine();

        System.out.println("username sent. message from server : " + receive);
        if (!receive.equals("334 UGFzc3dvcmQ6"))
            closing();


        //generate an api key and get its base64 encoding
        pr.println("U0cuN1g1c04zaDNTeHFBeXJGSjZhS01fQS56SGNRdC1qaVMxd2pXZjAyanhPQzVod3NoeTlNYXZWZ01hb0JxdVMtWUl3");
        receive = br.readLine();

        System.out.println("api sent. message from server : " + receive + "\n");
        if (!receive.equals("235 Authentication successful"))
            closing();
        //----------------------------------------------------------------

        //move to send command state
        sendCommand();
    }
    //------------------------------------------------------------------------------------
}
