import java.io.IOException;

public class timeOutThread implements Runnable {

    private int idx;

    public timeOutThread(int idx) {
        this.idx = idx;
    }

    @Override
    public void run() {
        //20 seconds
        long finishTime=System.currentTimeMillis()+(20*1000);
        while (Main.timerArray.get(idx)==false){
            if(System.currentTimeMillis()>=finishTime)break;
        }

        if(Main.timerArray.get(idx)==false)
        {
            System.out.println("timeout!!! server took more than 20 seconds to respond");
            try {
                Main.closing();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }
}
