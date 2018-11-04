import java.io.*;
import java.net.Socket;
import java.util.Date;

public class ClientThread implements Runnable {

    private BufferedReader br;
    private OutputStream outputStream;
    private PrintWriter pr;

    private String receive;
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

        System.out.println("\nserver accepted client no. "+clientId);
        System.out.println("client-" + clientId + " said: " + receive);

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
        //after a "GET /" the name of the required file is given
        System.out.println("----------------------------------------------\nGET logs\n");

        requiredFileName = "";
        for (int i = 5; ; ) {
            if (receive.charAt(i) == ' ') break;

            //if the web page has space in its name then the browser would send it as %20
            if (receive.charAt(i) == '%') {
                i += 3;
                requiredFileName += " ";
            } else {
                requiredFileName += receive.charAt(i);
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
        FileInputStream in;

        //404 error
        if (fileLength == 0)
        {
            requiredFileName = pathToFiles + "not_found_404.html";
            file = new File(requiredFileName);
            in = new FileInputStream(file);
            fileLength = (int) file.length();    //as we are opening a new file

            pr.println("HTTP/1.1 404 NOT FOUND");
            System.out.println("server wrote : HTTP/1.1 404 NOT FOUND");
            System.out.println("client-"+clientId+" said: "+br.readLine()+"\n");

        }

        else
        {
            in = new FileInputStream(file);

            pr.println("HTTP/1.1 200 OK");
            System.out.println("server wrote : HTTP/1.1 200 OK");
            System.out.println("client-"+clientId+" said: "+br.readLine()+"\n");
        }

        //System.out.println("file name: " + requiredFileName);
        //System.out.println("file type: " + getFileType());

        pr.println("Server: localhost:8080");
        System.out.println("server wrote : Server: localhost:8080");
        System.out.println("client-"+clientId+" said: "+br.readLine()+"\n");

        pr.println("Date: " + new Date());
        System.out.println("server wrote : Date");
        System.out.println("client-"+clientId+" said: "+br.readLine()+"\n");

        pr.println("Content-Type: " + getFileType());
        System.out.println("server wrote : Content-Type");
        System.out.println("client-"+clientId+" said: "+br.readLine()+"\n");

        pr.println("Content-Length: " + fileLength);
        System.out.println("server wrote : Content-Length:");
        System.out.println("client-"+clientId+" said: "+br.readLine()+"\n");

        pr.println();
        System.out.println("server wrote: empty line, ready to write bytes");
        System.out.println("client replied: "+br.readLine()+"\n");

        pr.flush();

        byte[] fileData = new byte[fileLength];
        in.read(fileData);

        outputStream.write(fileData, 0, fileLength);
        System.out.println("server wrote data");
        System.out.println("client-"+clientId+" said: "+br.readLine()+"\n");
        outputStream.flush();

        //read the whole file if it is a html so that we can process
        //further POST requests
        if (requiredFileName.endsWith("html")) {
            BufferedReader bufferedReader = new BufferedReader(new FileReader(file));

            Server.fileBackUp = "";
            String temp;
            while (true) {
                temp=bufferedReader.readLine();

                if(temp==null) break;

                Server.fileBackUp += temp;
                Server.fileBackUp+="\r\n";
            }
        }
    }
    //--------------------------------------------------------------------


    //--------------------------------------------------------------------
    void processPOST() throws IOException {

        if(!Server.fileBackUp.contains("Post->1505107"))
            Server.fileBackUp=Server.fileBackUp.replace("Post->", "Post->1505107");

        System.out.println("in");
        System.out.println("----------------------------------------------\nPOST logs\n");

        pr.println("HTTP/1.1 200 OK");
        System.out.println("server wrote: HTTP/1.1 200 OK");
        System.out.println("client replied: "+br.readLine()+"\n");

        pr.println("Server: localhost:8080");
        System.out.println("server wrote: Server: localhost:8080");
        System.out.println("client replied: "+br.readLine()+"\n");

        pr.println("Date: " + new Date());
        System.out.println("server wrote: the date");
        System.out.println("client replied: "+br.readLine()+"\n");

        pr.println("Content-Type: text\\html");
        System.out.println("server wrote: content-type");
        System.out.println("client replied: "+br.readLine()+"\n");

        pr.println("Content-Length: " + Server.fileBackUp.length());
        System.out.println("server wrote: content-length");
        System.out.println("client replied: "+br.readLine()+"\n");

        pr.println();
        System.out.println("server wrote: empty line, ready to write bytes");
        System.out.println("client replied: "+br.readLine()+"\n");

        pr.flush();

        System.out.println(Server.fileBackUp);
        byte[] fileData=Server.fileBackUp.getBytes();

        outputStream.write(fileData,0,Server.fileBackUp.length());
        System.out.println("server wrote: data");
        System.out.println("client replied: "+br.readLine()+"\n");

        outputStream.flush();

        System.out.println("----------------------------------------------\n");
    }
    //--------------------------------------------------------------------

}
