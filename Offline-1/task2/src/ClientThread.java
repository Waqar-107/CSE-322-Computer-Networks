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
    private File not_found_404;

    private boolean fileNotFound;

    //--------------------------------------------------------------------
    //init
    public ClientThread(Socket socket) throws IOException {
        this.socket = socket;

        br = new BufferedReader(new InputStreamReader(socket.getInputStream()));
        pr = new PrintWriter(socket.getOutputStream());
        outputStream = socket.getOutputStream();

        pathToFiles = "C:\\programming\\CSE-322-Computer-Networks\\Offline-1\\task2\\html_assets\\";
        not_found_404 = new File(pathToFiles + "404_Not_Found.html");
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

        System.out.println("file name: "+requiredFileName);

        //if the string is empty then return index
        if (requiredFileName.length() == 0)
            requiredFileName = "index.html";

        requiredFileName = pathToFiles + requiredFileName;


        //now if the file is found then return it otherwise return 404 not found
        file = new File(requiredFileName);
        sendFileData(file);
    }
    //--------------------------------------------------------------------


    //--------------------------------------------------------------------
    //send file to the browser with appropriate message of MIME
    void sendFileData(File file) throws IOException {
        FileInputStream in;
        byte[] fileData = new byte[(int) file.length()];

        //404 error
        if (file.length() == 0) {
            in = new FileInputStream(not_found_404);

            //the required file is missing so we are returning a html regardless of its type
            requiredFileName="html";

            pr.println("HTTP/1.1 404 NOT FOUND");
        } else {
            in = new FileInputStream(file);
            pr.println("HTTP/1.1 200 OK");
        }


        pr.println(new Date());
        pr.println("Server: localhost");
        pr.println("Content-Length " + file.length());
        pr.println(getFileType());

        in.read(fileData);
        System.out.println("sending data out");

        outputStream.write(fileData, 0, (int) file.length());
        socket.close();
    }
    //--------------------------------------------------------------------
}
