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

    private boolean fileNotFound;

    //--------------------------------------------------------------------
    //init
    public ClientThread(Socket socket) throws IOException {
        this.socket = socket;

        br = new BufferedReader(new InputStreamReader(socket.getInputStream()));
        pr = new PrintWriter(socket.getOutputStream());
        outputStream = socket.getOutputStream();

        pathToFiles = "C:\\programming\\CSE-322-Computer-Networks\\Offline-1\\task2\\html_assets\\";

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

        System.out.println("client said: " + receive);

        if (receive.startsWith("GET")) {
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
            return "text/pdf";

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
            if(receive.charAt(i)=='%')
            {
                i+=3;
                requiredFileName+=" ";
            }

            else
            {
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

        if(!requiredFileName.endsWith("favicon.ico"))
            sendFileData(file);
    }
    //--------------------------------------------------------------------


    //--------------------------------------------------------------------
    //send file to the browser with appropriate message of MIME
    void sendFileData(File file) throws IOException {

        int fileLength= (int) file.length();

        FileInputStream in;
        byte[] fileData = new byte[fileLength];

        //404 error
        if (fileLength == 0)
        {
            requiredFileName=pathToFiles+"Not_Found.html";
            file=new File(requiredFileName);
            in = new FileInputStream(file);

            System.out.println("404 not f dicchi");
            pr.println("HTTP/1.1 404 NOT FOUND");
        }

        else
        {
            in = new FileInputStream(file);
            pr.println("HTTP/1.1 200 OK");
        }

        System.out.println("2 file name: "+requiredFileName);
        System.out.println("2 file type: "+getFileType());

        pr.println("Server: localhost:8080");
        pr.println("Date: "+new Date());
        pr.println("Content-Type: "+getFileType());
        pr.println("Content-Length: " + fileLength);

        pr.println(); pr.flush();

        in.read(fileData);

        outputStream.write(fileData, 0, fileLength);
        outputStream.flush();

        socket.close();
    }
    //--------------------------------------------------------------------
}
