import java.io.*;
import java.net.*;
import java.util.ArrayList;
import java.util.Scanner;

public class Client {

    private static Socket smtpSocket;
    private static BufferedReader br;
    private static PrintWriter pr;

    public static void closing() throws IOException {
        smtpSocket.close();
        br.close();
        pr.close();
        System.exit(0);
    }

    public static void main(String[] args) throws IOException {

        //----------------------------------------------------------------
        //init
        String mailServerAddress = "localhost";

        InetAddress mailHost = InetAddress.getByName(mailServerAddress);
        InetAddress localHost = InetAddress.getLocalHost();

        smtpSocket = new Socket(mailHost, 25);

        br = new BufferedReader(new InputStreamReader(smtpSocket.getInputStream()));
        pr = new PrintWriter(smtpSocket.getOutputStream(), true);  //no need to call flush

        String receivedFromServer, sendToServer, recipientMailID;
        Scanner in = new Scanner(System.in);

        ArrayList<String> recipients = new ArrayList<>();
        ArrayList<String> errs = new ArrayList<>();
        //----------------------------------------------------------------


        //----------------------------------------------------------------
        //after connecting smtp server shall send 220 and some strings concatenated with it
        String initialID = br.readLine();

        if (initialID.startsWith("220"))
            System.out.println("initial id sent by the server: " + initialID);
        else {
            System.out.println("error!!! " + initialID + " - sent by the server");
            closing();
        }
        //----------------------------------------------------------------


        //----------------------------------------------------------------
        //say hello to the server
        sendToServer="HELO "+localHost.getHostName();
        pr.println(sendToServer);
        receivedFromServer=br.readLine();
        System.out.println("we said HELO, server said -"+receivedFromServer+"\n");
        //----------------------------------------------------------------


        //----------------------------------------------------------------
        /*
         * the transaction is started with a MAIL command which gives the sender
         * identification. if accepted the receiver-SMTP returns a "250 OK" reply.
         */

        System.out.println("please enter your email address(without any qoutes)");
        //String sendersMailAddress= in.nextLine();
        String sendersMailAddress = "waqar.hassan866@gmail.com";
        sendToServer = "MAIL FROM:<" + sendersMailAddress + ">";

        pr.println(sendToServer);
        receivedFromServer = br.readLine();

        if (!receivedFromServer.equals("250 Ok")) {
            System.out.println("error in your mail address. message from server: " + receivedFromServer);
            closing();
        } else {
            System.out.println("everything fine with the mail address. message from server: " + receivedFromServer);
        }
        //----------------------------------------------------------------


        //----------------------------------------------------------------
        /*
         * A series of one or more RCPT commands follows giving the receiver
         * information. If accepted, the receiver-SMTP returns a 250 OK reply,
         * and stores the forward-path. If the recipient is unknown the
         * receiver-SMTP returns a 550 Failure reply.
         */
        int n;
        System.out.println("enter the number of recipients");
        //n=in.nextInt();
        n = 1;
        System.out.println("enter " + n + " mail id's in each line");
        /*for (int i = 0; i < n; i++) {
            recipientMailID = in.nextLine();
            recipients.add(recipientMailID);
        }*/
        recipientMailID = "1505107.whk@ugrad.buet.ac.bd.ad";
        recipients.add(recipientMailID);
        recipientMailID = "1505101.tbh@ugrad.buet.ac.bd.ad";
        recipients.add(recipientMailID);

        for (String s : recipients) {
            recipientMailID = "RCPT TO:<" + s + ">";

            pr.println(recipientMailID);
            receivedFromServer = br.readLine();

            if (receivedFromServer.equals("250 Ok"))
                System.out.println("recipient mail address: " + s + " is ok. message from server : " + receivedFromServer);

            else {
                System.out.println("error in recipient mail address: " + s + " message from server : " + receivedFromServer);
                errs.add(s);
            }
        }

        for (String s : errs)
            recipients.remove(errs);
        //----------------------------------------------------------------


        //----------------------------------------------------------------
        /*
         * Then a DATA command gives the mail data. If accepted,
         * the receiver-SMTP returns a 354 Intermediate reply and considers
         * all succeeding lines to be the message text. And finally, the end
         * of mail data indicator confirms the transaction. When the end of text
         * is received and stored the SMTP-receiver sends a 250 OK reply.
         */
        sendToServer = "DATA";
        pr.println(sendToServer);
        receivedFromServer = br.readLine();

        if (!receivedFromServer.equals("354 End data with <CR><LF>.<CR><LF>")) {
            System.out.println("can't send mail. message from server : " + receivedFromServer);
            closing();
        }

        else
            System.out.println("sending mail. message from server : "+receivedFromServer);
        //----------------------------------------------------------------


        //----------------------------------------------------------------
        String message = "testing smtp code";

        pr.println(message);
        pr.println(".");
        receivedFromServer = br.readLine();
        if (receivedFromServer.equals("250 Ok"))
            System.out.println("mail sent!!!. message from server : " + receivedFromServer);

        else {
            System.out.println("error sending mail. message from server : " + receivedFromServer);
            closing();
        }
        //----------------------------------------------------------------


        //----------------------------------------------------------------
        //quit
        sendToServer = "QUIT";
        pr.println(sendToServer);
        receivedFromServer = br.readLine();

        if(receivedFromServer.startsWith("221"))
            System.out.println("successfully sent mail");
        else
            System.out.println("mail was not sent");

        System.out.println("message from server : "+receivedFromServer);
        closing();
        //----------------------------------------------------------------
    }
}
