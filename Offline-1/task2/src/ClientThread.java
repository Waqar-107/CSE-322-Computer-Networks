import java.io.*;
import java.net.Socket;
import java.util.Date;

public class ClientThread implements Runnable {

    private BufferedReader br;
    private OutputStream outputStream;
    private PrintWriter pr;

    private String receive, linkFromBrowser, fileToPost;
    private String requiredFileName;
    private String pathToFiles;

    private Socket socket;
    private File file;

    private int clientId;

    //--------------------------------------------------------------------
    //init
    public ClientThread(Socket socket, int clientId) throws IOException {
        this.socket = socket;
        this.clientId = clientId;

        br = new BufferedReader(new InputStreamReader(socket.getInputStream()));
        pr = new PrintWriter(socket.getOutputStream());
        outputStream = socket.getOutputStream();

        pathToFiles = "C:\\programming\\CSE-322-Computer-Networks\\Offline-1\\task2\\html_assets\\";
    }
    //--------------------------------------------------------------------


    //--------------------------------------------------------------------
    //close everything
    void closeEverything() throws IOException {
        br.close();
        pr.close();
        socket.close();
    }
    //--------------------------------------------------------------------


    //--------------------------------------------------------------------
    //run
    @Override
    public void run() {

        //read from the client
        try {
            receive = br.readLine();
        } catch (IOException e) {
            e.printStackTrace();
        }

        System.out.println("\nserver accepted client no. " + clientId);
        System.out.println("client-" + clientId + " said: " + receive);

        //in a GET request, the first line will have the requested file name
        linkFromBrowser = receive;

        if (receive != null && receive.startsWith("GET")) {
            try {
                processGet();
            } catch (IOException e) {
                e.printStackTrace();
            }
        } else if (receive != null && receive.startsWith("POST")) {
            try {
                processPOST();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }
    //--------------------------------------------------------------------


    //--------------------------------------------------------------------
    //get the file type
    String getFileType() {
        if (requiredFileName.endsWith("html"))
            return "text/html";

        else if (requiredFileName.endsWith("bmp"))
            return "image/bmp";

        else if (requiredFileName.endsWith("jpg"))
            return "image/jpeg";

        else if (requiredFileName.endsWith("pdf"))
            return "application/pdf";

        else if (requiredFileName.endsWith("png"))
            return "image/png";

        else
            return "text/plain";
    }
    //--------------------------------------------------------------------


    //--------------------------------------------------------------------
    //process a GET request
    void processGet() throws IOException {

        //-------------------------------------------------logs
        System.out.println("----------------------------------------------GET logs\n");
        while (true) {
            receive = br.readLine();
            if (receive.length() == 0) break;
            System.out.println("client-" + clientId + " said: " + receive);
        }
        //-------------------------------------------------logs

        requiredFileName = "";
        for (int i = 5; ; ) {
            if (linkFromBrowser.charAt(i) == ' ') break;

            //if the web page has space in its name then the browser would send it as %20
            if (linkFromBrowser.charAt(i) == '%') {
                i += 3;
                requiredFileName += " ";
            } else {
                requiredFileName += linkFromBrowser.charAt(i);
                i++;
            }
        }

        //if the string is empty then return index
        if (requiredFileName.length() == 0)
            requiredFileName = "index.html";

        requiredFileName = pathToFiles + requiredFileName;

        //now if the file is found then return it otherwise return 404 not found
        file = new File(requiredFileName);

        if (!requiredFileName.contains("favicon.ico"))
            sendFileData(file);
    }
    //--------------------------------------------------------------------


    //--------------------------------------------------------------------
    //send file to the browser with appropriate message of MIME
    void sendFileData(File file) throws IOException {

        int fileLength = (int) file.length();
        FileInputStream fileInputStream;

        //404 error
        if (fileLength == 0) {
            requiredFileName = pathToFiles + "not_found_404.html";
            file = new File(requiredFileName);
            fileInputStream = new FileInputStream(file);
            fileLength = (int) file.length();    //as we are opening a new file

            pr.println("HTTP/1.1 404 NOT FOUND");
            System.out.println("server wrote : HTTP/1.1 404 NOT FOUND");
        } else {
            fileInputStream = new FileInputStream(file);

            pr.println("HTTP/1.1 200 OK");
            System.out.println("server wrote : HTTP/1.1 200 OK");
        }

        //System.out.println("file name: " + requiredFileName);
        //System.out.println("file type: " + getFileType());

        pr.println("Server: localhost:8080");
        System.out.println("server wrote : Server: localhost:8080");

        pr.println("Date: " + new Date());
        System.out.println("server wrote : Date");

        pr.println("Content-Type: " + getFileType());
        System.out.println("server wrote : Content-Type");

        pr.println("Content-Length: " + fileLength);
        System.out.println("server wrote : Content-Length:");

        pr.println();
        System.out.println("server wrote: empty line, ready to write bytes");

        pr.flush();

        byte[] fileData = new byte[fileLength];
        fileInputStream.read(fileData);

        System.out.println("server wrote data");
        outputStream.write(fileData, 0, fileLength);
        outputStream.flush();

        closeEverything();
    }
    //--------------------------------------------------------------------


    //--------------------------------------------------------------------
    void processPOST() throws IOException {

        int contentLen = 0;
        StringBuilder stringBuilder = new StringBuilder();
        char ch;

        //-------------------------------------------------logs
        System.out.println("----------------------------------------------POST logs\n");

        while (true) {
            receive = br.readLine();
            if (receive.length() == 0) break;

            System.out.println("client-" + clientId + " said: " + receive);

            if (receive.startsWith("Referer:"))
                linkFromBrowser = receive;

            if (receive.startsWith("Content-Length")) {
                for (int i = receive.length() - 1; i >= 0; i--) {
                    if (receive.charAt(i) == ' ') break;
                    stringBuilder.append(receive.charAt(i));
                }

                contentLen = Integer.parseInt(stringBuilder.reverse().toString());
            }
        }

        //now start reading char by char
        stringBuilder = new StringBuilder();
        for (int i = 0; i < contentLen; i++) {
            ch = (char) br.read();
            stringBuilder.append(ch);
        }

        System.out.println("client-" + clientId + " said: " + stringBuilder.toString());

        String requestedValues = stringBuilder.toString();
        //-------------------------------------------------logs

        //now we have the link of the webpage as well as the posted value
        stringBuilder = new StringBuilder();
        for (int i = linkFromBrowser.length() - 1; i >= 0; i--) {
            if (linkFromBrowser.charAt(i) == '/')
                break;

            stringBuilder.append(linkFromBrowser.charAt(i));
        }

        linkFromBrowser = stringBuilder.reverse().toString();
        linkFromBrowser = linkFromBrowser.replace("%20", " ");

        //open the link
        System.out.println("open: " + pathToFiles + linkFromBrowser);
        file = new File(pathToFiles + linkFromBrowser);

        if (file.length() == 0) {
            sendFileData(new File(linkFromBrowser + "not_found_404.html"));
        } else {
            BufferedReader in = new BufferedReader(new FileReader(file));

            fileToPost = "";
            while (true) {
                receive = in.readLine();
                if (receive == null) break;
                fileToPost += receive + "\r\n";
            }

            //now replace POST-> with POST->name where user=name
            String[] sarr = requestedValues.split("&");
            String[] sarr2 = sarr[0].split("=");

            fileToPost=fileToPost.replaceFirst("Post-> ", "Post-> " + sarr2[1]);

            //now convert the string into byte array and write
            byte[] fs=fileToPost.getBytes();

            //send information about what you are sending
            System.out.println("server wrote : HTTP/1.1 200 OK");
            pr.println("HTTP/1.1 200 OK");

            System.out.println("server wrote : Server: localhost:8080");
            pr.println("Server: localhost:8080");

            System.out.println("server wrote : Date");
            pr.println("Date : "+new Date());

            System.out.println("server wrote : Content-Type");
            pr.println("Content-Type: text/html");

            System.out.println("server wrote : Content-Length:");
            pr.println("Content-Length: " + fileToPost.length());

            System.out.println("server wrote: empty line, ready to write bytes");
            pr.println();

            pr.flush();

            outputStream.write(fs);
            outputStream.flush();

            closeEverything();
        }
    }
    //--------------------------------------------------------------------

}
