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
        this.clientId=clientId;

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

        System.out.println("client-"+clientId+" said: " + receive);

        if (receive!=null && receive.startsWith("GET")) {
            try {
                processGet();
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
        requiredFileName = "";
        for (int i = 5; ;) {
            if (receive.charAt(i) == ' ') break;

            //if the web page has space in its name then the browser would send it as %20
            if(receive.charAt(i)=='%') {
                i+=3;
                requiredFileName+=" ";
            }

            else {
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

        if(!requiredFileName.contains("favicon.ico"))
            sendFileData(file);
    }
    //--------------------------------------------------------------------


    //--------------------------------------------------------------------
    //send file to the browser with appropriate message of MIME
    void sendFileData(File file) throws IOException {

        int fileLength= (int) file.length();

        FileInputStream in;

        //404 error
        if (fileLength == 0)
        {
            requiredFileName=pathToFiles+"not_found_404.html";
            file=new File(requiredFileName);
            in = new FileInputStream(file);
            fileLength= (int) file.length();    //as we are opening a new file

            pr.println("HTTP/1.1 404 NOT FOUND");
        }

        else
        {
            in = new FileInputStream(file);
            pr.println("HTTP/1.1 200 OK");
        }

        System.out.println("file name: "+requiredFileName);
        System.out.println("file type: "+getFileType());

        pr.println("Server: localhost:8080");
        pr.println("Date: "+new Date());
        pr.println("Content-Type: "+getFileType());
        pr.println("Content-Length: " + fileLength);

        pr.println(); pr.flush();

        byte[] fileData = new byte[fileLength];
        in.read(fileData);

        outputStream.write(fileData, 0, fileLength);
        outputStream.flush();
    }
    //--------------------------------------------------------------------
}
