import java.io.*;
import java.net.InetAddress;
import java.net.Socket;

public class Main {

    private static Socket smtpSocket;
    private static BufferedReader br;
    private static PrintWriter pr;
    private static BufferedReader readAddress, readMail, userInput;
    private static String receive, input;

    private static File mailAdresses, mailBody;

    //------------------------------------------------------------------------------------
    //close evrything and exit
    public static void closing() throws IOException {
        System.out.println("\nclosing down everything");

        br.close();
        pr.close();
        smtpSocket.close();

        System.exit(1);
    }
    //------------------------------------------------------------------------------------


    //------------------------------------------------------------------------------------
    //get response from the server
    public static void getResponse() throws IOException {
        receive = br.readLine();
        System.out.println("server says: " + receive + "\n");

        //if error then quit from here
        if (receive.startsWith("2") || receive.startsWith("354") || receive.startsWith("334"))
            return;

        closing();
    }
    //------------------------------------------------------------------------------------


    //------------------------------------------------------------------------------------
    //send message to server
    public static void sendResponse(String str) {
        if (str.length() > 0)
            pr.println(str);
        else
            pr.println();
    }
    //------------------------------------------------------------------------------------


    //------------------------------------------------------------------------------------
    public static void sendCommand() throws IOException {
        while (true) {
            System.out.println("enter command to send to the smtp server-");

            input = userInput.readLine();

            if (input.equalsIgnoreCase("helo")) {
                sendResponse("HELO");
                getResponse();
            } else if (input.equalsIgnoreCase("rset")) {
                sendResponse("RSET");
                getResponse();
            } else if (input.equalsIgnoreCase("NOOP")) {
                sendResponse("NOOP");
                getResponse();
            } else if (input.equalsIgnoreCase("mail")) {
                receive = readAddress.readLine();
                if (receive == null) {
                    System.out.println("EOF");
                    closing();
                }

                sendResponse("MAIL FROM:<" + receive + ">");
                getResponse();
            } else if (input.equalsIgnoreCase("rcpt")) {
                receive = readAddress.readLine();
                if (receive == null) {
                    System.out.println("EOF");
                    closing();
                }

                sendResponse("RCPT TO:<" + receive + ">");
                getResponse();
            } else if (input.equalsIgnoreCase("data")) {
                sendResponse("DATA");
                getResponse();

                while (true) {
                    receive = readMail.readLine();
                    if (receive == null) break;
                    //System.out.println(receive);
                    sendResponse(receive);sendResponse(" ");
                }

                //System.out.println("mail sent");
                sendResponse(".");
                getResponse();
            } else if (input.equalsIgnoreCase("quit")) {
                sendResponse("QUIT");
                getResponse();
                closing();
            }
        }
    }
    //------------------------------------------------------------------------------------


    //------------------------------------------------------------------------------------
    public static void sendData() throws IOException {

    }
    //------------------------------------------------------------------------------------


    //------------------------------------------------------------------------------------
    public static void main(String[] args) throws IOException {
        String mailServerAddress = "smtp.sendgrid.net";

        InetAddress mailHost = InetAddress.getByName(mailServerAddress);
        InetAddress localHost = InetAddress.getLocalHost();

        smtpSocket = new Socket(mailHost, 587);

        br = new BufferedReader(new InputStreamReader(smtpSocket.getInputStream()));
        pr = new PrintWriter(smtpSocket.getOutputStream(), true);

        userInput = new BufferedReader(new InputStreamReader(System.in));

        mailAdresses = new File("C:\\programming\\CSE-322-Computer-Networks\\Offline-1\\task1\\src\\mail_addresses.txt");
        mailBody = new File("C:\\programming\\CSE-322-Computer-Networks\\Offline-1\\task1\\src\\mail_body.txt");

        readAddress = new BufferedReader(new FileReader(mailAdresses));
        readMail = new BufferedReader(new FileReader(mailBody));

        //----------------------------------------------------------------
        //after connecting smtp server shall send 220 and some strings concatenated with it
        getResponse();

        if (receive.startsWith("220"))
            System.out.println("connected. message from server : " + receive + "\n");
        else {
            System.out.println("error!!! message from server" + receive + "\n");
            closing();
        }
        //----------------------------------------------------------------

        //----------------------------------------------------------------
        //authenticate using username and api-key for authorization of sending mail
        sendResponse("AUTH LOGIN");
        getResponse();

        System.out.println("requested for authentication .message from server : " + receive);
        if (!receive.equals("334 VXNlcm5hbWU6"))
            closing();

        //send your username - base64 encoding of "apikey"
        sendResponse("YXBpa2V5");
        getResponse();

        System.out.println("username sent. message from server : " + receive);
        if (!receive.equals("334 UGFzc3dvcmQ6"))
            closing();


        //generate an api key and get its base64 encoding
        sendResponse("U0cuN1g1c04zaDNTeHFBeXJGSjZhS01fQS56SGNRdC1qaVMxd2pXZjAyanhPQzVod3NoeTlNYXZWZ01hb0JxdVMtWUl3");
        getResponse();

        System.out.println("api sent. message from server : " + receive + "\n");
        if (!receive.equals("235 Authentication successful"))
            closing();
        //----------------------------------------------------------------

        //connection and authentication done. move to send command state
        sendCommand();
    }
    //------------------------------------------------------------------------------------
}
