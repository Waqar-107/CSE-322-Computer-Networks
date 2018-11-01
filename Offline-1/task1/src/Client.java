import java.io.*;
import java.net.*;
import java.util.ArrayList;
import java.util.Scanner;

public class Client {

    private static Socket smtpSocket;
    private static BufferedReader br;
    private static PrintWriter pr;

    //private static

    public static void closing() throws IOException {
        smtpSocket.close();
        br.close();
        pr.close();
        System.exit(0);
    }
    
    private static void print(String str){
        System.out.println(str);
    }

    public static void main(String[] args) throws IOException {

        //----------------------------------------------------------------
        //init

        String mailServerAddress = "smtp.sendgrid.net";

        InetAddress mailHost = InetAddress.getByName(mailServerAddress);
        InetAddress localHost = InetAddress.getLocalHost();

        smtpSocket = new Socket(mailHost, 587);

        br = new BufferedReader(new InputStreamReader(smtpSocket.getInputStream()));
        pr = new PrintWriter(smtpSocket.getOutputStream(), true);  //no need to call flush

        String receivedFromServer, sendToServer, recipientMailID;

        Scanner in=new Scanner(System.in);
        
        ArrayList<String> recipients=new ArrayList<>();
        //----------------------------------------------------------------


        //----------------------------------------------------------------
        //after connecting smtp server shall send 220 and some strings concatenated with it
        String initialID = br.readLine();

        if (initialID.startsWith("220"))
            print("connected. message from server : " + initialID);
        else {
            print("error!!! message from server" + initialID);
            closing();
        }
        //----------------------------------------------------------------


        //----------------------------------------------------------------
        //authenticate using username and api-key for authorization of sending mail
        pr.println("AUTH LOGIN");
        receivedFromServer=br.readLine();
        print("requested for authenitation. message from server : "+receivedFromServer);


        //send your username - base64 encoding of "apikey"
        pr.println("YXBpa2V5");
        receivedFromServer=br.readLine();
        print("username sent. message from server : "+receivedFromServer);

        //generate an api key and get its base64 encoding
        pr.println("U0cuN1g1c04zaDNTeHFBeXJGSjZhS01fQS56SGNRdC1qaVMxd2pXZjAyanhPQzVod3NoeTlNYXZWZ01hb0JxdVMtWUl3");
        receivedFromServer=br.readLine();
        print("api sent. message from server : "+receivedFromServer+"\n");
        //----------------------------------------------------------------


        //----------------------------------------------------------------
        //say hello to the server
        sendToServer="HELO "+localHost.getHostName();
        pr.println(sendToServer);
        receivedFromServer=br.readLine();
        print("we said: HELO, message from server : "+receivedFromServer+"\n");
        //----------------------------------------------------------------


        //----------------------------------------------------------------
        /*
         * the transaction is started with a MAIL command which gives the sender
         * identification. if accepted the receiver-SMTP returns a "250 OK" reply.
         */

        print("please enter your email address(without any qoutes)");
        String sendersMailAddress= in.next();
        sendToServer = "MAIL FROM:<" + sendersMailAddress + ">";

        pr.println(sendToServer);
        receivedFromServer = br.readLine();

        if (!receivedFromServer.startsWith("250")) {
            print("error in your mail address - '"+sendersMailAddress+"'. message from server: " + receivedFromServer+"\n");
            closing();
        } else {
            print("everything fine with the senders mail address. message from server: " + receivedFromServer+"\n");
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
        print("\nenter the number of recipients");

        n=in.nextInt();
        print("enter " + n + " mail id's in each line");
        for (int i = 0; i < n; i++) {
            recipientMailID = in.next();
            recipients.add(recipientMailID);
        }

        for (String s : recipients) {
            recipientMailID = "RCPT TO:<" + s + ">";

            pr.println(recipientMailID);
            receivedFromServer = br.readLine();

            if (receivedFromServer.startsWith("250"))
                print("recipient mail address: " + s + " is ok. message from server : " + receivedFromServer);

            else {
                print("error in recipient mail address: " + s + " message from server : " + receivedFromServer);
            }
        }
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

        if (!receivedFromServer.equals("354 Continue")) {
            print("\ncan't send mail. message from server : " + receivedFromServer);
            closing();
        }

        else
            print("\nsending mail. message from server : "+receivedFromServer);
        //----------------------------------------------------------------


        //----------------------------------------------------------------
        String subject, message;

        //send the subject
        print("enter the subject of your mail");
        subject=in.next();
        subject=subject+in.nextLine();

        pr.println("Subject: "+subject);

        //send from
        pr.println("From: "+sendersMailAddress+"");

        //send to
        for(String s : recipients)
            pr.println("To: "+s);


        //now a newline
        pr.println();

        //get the message and send it line by line
        print("enter your message below. to indicate the end of the message body, enter _end_ in a seperate line");
        while(true)
        {
            message=in.nextLine();
            if(message.equals("_end_"))
                break;
            else
                pr.println(message);
        }

        //indicate the end
        pr.println(".");
        receivedFromServer = br.readLine();
        if (receivedFromServer.startsWith("250"))
            print("mail sent!!!. message from server : " + receivedFromServer);

        else {
            print("error sending mail. message from server : " + receivedFromServer);
            closing();
        }
        //----------------------------------------------------------------


        //----------------------------------------------------------------
        //quit
        sendToServer = "QUIT";
        pr.println(sendToServer);
        receivedFromServer = br.readLine();

        print("we quit the process. message from server : "+receivedFromServer);

        in.close();
        closing();
        //----------------------------------------------------------------
    }
}

/*
* waqar.hassan866@gmail.com
* anfuad@yahoo.com
* tameem.bin.haider.101@gmail.com
*/