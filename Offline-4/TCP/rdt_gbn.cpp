/* ******************************************************************
 ALTERNATING BIT AND GO-BACK-N NETWORK EMULATOR: SLIGHTLY MODIFIED
 FROM VERSION 1.1 of J.F.Kurose

   This code should be used for PA2, unidirectional or bidirectional
   data transfer protocols (from A to B. Bidirectional transfer of data
   is for extra credit and is not required).  Network properties:
   - one way network delay averages five time units (longer if there
       are other messages in the channel for GBN), but can be larger
   - packets can be corrupted (either the header or the data portion)
       or lost, according to user-defined probabilities
   - packets will be delivered in the order in which they were sent
       (although some can be lost).
**********************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <vector>
#include <queue>

//=================================================
//1505107 - defines
#define pfs(s) printf("%s", s)
#define SZ 20
#define MOD 8
#define WINDOW_SZ 5
#define BUFFER_SZ 5

#define dbg printf("in\n")
#define nl printf("\n")

#define _A_ 0
#define _B_ 1
//=================================================

using namespace std;

/* a "msg" is the data unit passed from layer 5 (teachers code) to layer
 * 4 (students' code).  It contains the data (characters) to be delivered
 * to layer 5 via the students transport level protocol entities.*/
struct msg {
  char data[20];
};

/* a packet is the data unit passed from layer 4 (students code) to layer
 * 3 (teachers code).  Note the pre-defined packet structure, which all
 * students must follow. */
struct pkt {
  int seqnum;
  int acknum;
  int checksum;
  char payload[20];
};

//=================================================
//1505107 - global variables
int msgNo = 1;
struct pkt pktA, pktB;
int nxtSeqNum_A;
int expectedSeq_B, lastSuccessfull_B;
char _ACK_[SZ], _NAK_[SZ];
float time_threshold = 50.0;

vector<pkt> window;
queue<pkt> buffer;
//=================================================


//=================================================
//FUNCTION PROTOTYPES. DEFINED IN THE LATER PART
void starttimer(int AorB, float increment);
void stoptimer(int AorB);
void tolayer3(int AorB, struct pkt packet);
void tolayer5(int AorB, char datasent[20]);
//=================================================

//=================================================================================================
//  STUDENTS WRITE THE NEXT SEVEN ROUTINES

//=================================================
//utilities
int getSum(char a[SZ]) {
  int i, sum = 0;
  for (i = 0; i < SZ; i++)
    sum += (int) a[i];

  return sum;
}

void printPktDetail(struct pkt packet) {
  printf("seq: %d | ack: %d | checksum: %d\n\n",
         packet.seqnum,
         packet.acknum,
         packet.checksum);
}

int getCheckSum(struct pkt packet) {
  return getSum(packet.payload) + packet.seqnum + packet.acknum;
}

bool isCorrupted(struct pkt packet) {
  int c_sum = getCheckSum(packet);
  return !(c_sum == packet.checksum);
}
//=================================================


//=================================================
// the following routine will be called once (only) before any other
// entity A routines are called. You can use it to do any initialization
void A_init(void) {
  nxtSeqNum_A = 0;
}
//=================================================


//=================================================
//the following routine will be called once (only) before any other
//entity B routines are called. You can use it to do any initialization
void B_init(void) {
  expectedSeq_B = 0;
  lastSuccessfull_B = -1;
  strncpy(_ACK_, "ack_________________", SZ);
  strncpy(_NAK_, "nak_________________", SZ);
}
//=================================================


//=================================================
//if window has more space then send, window space decreases
//if there is no space in the window then try to insert in the buffer
//if no space left in the buffer then refuse to take from layer5
void A_output(struct msg message) {
  //drop
  if (window.size() == WINDOW_SZ && buffer.size() == BUFFER_SZ) {
    pfs("***WINDOW AND BUFFER BOTH ARE FULL, UNABLE TO SEND DATA***\n");
  } else {
    //make a pkt
    struct pkt packet;
    strncpy(packet.payload, message.data, SZ);
    packet.seqnum = nxtSeqNum_A;
    packet.acknum = nxtSeqNum_A;
    nxtSeqNum_A = (nxtSeqNum_A + 1) % MOD;
    packet.checksum = getCheckSum(packet);

    if (window.size() < WINDOW_SZ) {
      window.push_back(packet);
      tolayer3(_A_, packet);

      if (window.size() == 1)
        starttimer(_A_, time_threshold);
    } else
      buffer.push(packet);
  }
}
//=================================================


//=================================================
//called from layer 3, when a packet arrives for layer 4
//ACK packet from B to A
void A_input(struct pkt packet) {
  printf("i am in a input, packet corruption stat: %d\n\n",isCorrupted(packet));
  if (isCorrupted(packet)) {
    pfs("packet received at A is corrupted, ignoring...\n");
    return;
  }
printf("stopping the time in A\n");
  //stop the timer
  stoptimer(_A_);

  //check if the ack no. is in the window
  int idx = -1;
  for (int i = 0; i < window.size(); i++) {
    if (window[i].seqnum == packet.acknum) {
      idx = i;
      break;
    }
  }

  //duplicate ack
  if (idx == -1) {
    printf("duplicate ack found, resending the whole window\n");
    stoptimer(_A_);

    for (pkt p : window)
      tolayer3(_A_, p);

    if(window.size())
      starttimer(_A_, time_threshold);

    return;
  }

  //all the pkts upto the acknum is accepted
  //as the receiver accepts pkt sequentially
  for (int i = 0; i <= idx; i++)
    printf("%dth msg tranmitted successfully\n", msgNo++);

  window.erase(window.begin(), window.begin() + idx + 1);

  struct pkt temp;
  while (buffer.size()) {
    if (window.size() < WINDOW_SZ){
      temp = buffer.front(), window.push_back(temp), buffer.pop();
      tolayer3(_A_,temp);
    }
    else break;
  }

  //if any packet in the window then restart time
  if(window.size())
    starttimer(_A_, time_threshold);

}
//=================================================


//=================================================
//called when A's timer goes off
void A_timerinterrupt(void) {
  pfs("timeout occurred while sending pkt from A to B, resending all the packets of the window...\n");

  for (pkt p : window)
    tolayer3(_A_, p);

  starttimer(_A_, time_threshold);
}
//=================================================


//=================================================
// BONUS PART - NOT REQUIRED IN THIS PROTOCOL
//need be completed only for extra credit
void B_output(struct msg message) {}
/* Note that with simplex transfer from a-to-B, there is no B_output() */
//=================================================


//=================================================
//called from layer 3, when a packet arrives for layer 4 at B
void B_input(struct pkt packet) {
  pfs("pkt arrived at B\n");
  printf("checksum received: %d, checksum calculated: %d\n", packet.checksum, getCheckSum(packet));
  printf("expected seq: %d | received seq: %d\n", expectedSeq_B, packet.seqnum);

  //case 1.2 and 2(from the spec)
  if (isCorrupted(packet) || expectedSeq_B != packet.seqnum) {
    pktB.acknum = lastSuccessfull_B;
    pktB.seqnum = expectedSeq_B;
    pktB.checksum = getSum(_NAK_) + pktB.acknum + pktB.seqnum;
    strncpy(pktB.payload, _NAK_, SZ);

    tolayer3(_B_, pktB);
    pfs("B sent nak\n");
  }

    //case 1.1
  else {
    //sent ack to layer-3 and the data to layer-5
    tolayer5(_B_, packet.payload);

    pktB.acknum = expectedSeq_B;
    pktB.seqnum = expectedSeq_B;
    pktB.checksum = getSum(_ACK_) + pktB.acknum + pktB.seqnum;
    strncpy(pktB.payload, _ACK_, SZ);

    lastSuccessfull_B = expectedSeq_B % MOD;
    expectedSeq_B = (expectedSeq_B + 1) % MOD;

    tolayer3(_B_, pktB);
    pfs("B sent ack, B sent data\n");
  }
}
//=================================================


//=================================================
//called when B's timer goes off
//not used in this protocol
void B_timerinterrupt(void) {
  printf("  B_timerinterrupt: B doesn't have a timer. ignore.\n");
}
//=================================================


//=================================================================================================
/*****************************************************************
***************** NETWORK EMULATION CODE STARTS BELOW ***********
The code below emulates the layer 3 and below network environment:
    - emulates the transmission and delivery (possibly with bit-level corruption
        and packet loss) of packets across the layer 3/4 interface
    - handles the starting/stopping of a timer, and generates timer
        interrupts (resulting in calling students timer handler).
    - generates message to be sent (passed from later 5 to 4)

THERE IS NOT REASON THAT ANY STUDENT SHOULD HAVE TO READ OR UNDERSTAND
THE CODE BELOW.  YOU SHOULD NOT TOUCH, OR REFERENCE (in your code) ANY
OF THE DATA STRUCTURES BELOW.  If you're interested in how I designed
the emulator, you're welcome to look at the code - but again, you should have
to, and you definitely should not have to modify
******************************************************************/

struct event {
  float evtime;       /* event time */
  int evtype;         /* event type code */
  int eventity;       /* entity where event occurs */
  struct pkt *pktptr; /* ptr to packet (if any) assoc w/ this event */
  struct event *prev;
  struct event *next;
};
struct event *evlist = NULL; /* the event list */

#define BIDIRECTIONAL 0   //if the protocol is bidirectional

/* possible events: */
#define TIMER_INTERRUPT 0
#define FROM_LAYER5 1
#define FROM_LAYER3 2

#define OFF 0
#define ON 1
#define A 0
#define B 1

int TRACE = 1;     /* for my debugging */
int nsim = 0;      /* number of messages from 5 to 4 so far */
int nsimmax = 0;   /* number of msgs to generate, then stop */
float time = 0.000;
float lossprob;    /* probability that a packet is dropped  */
float corruptprob; /* probability that one bit is packet is flipped */
float lambda;      /* arrival rate of messages from layer 5 */
int ntolayer3;     /* number sent into layer 3 */
int nlost;         /* number lost in media */
int ncorrupt;      /* number corrupted by media*/

void init();
void generate_next_arrival(void);
void insertevent(struct event *p);

void B_output(struct msg msg);
int main() {

  //--------------------------------------------------------------------------------------
  // edit in the emulator by 1505107 -> taking input from a txt and giving output in a txt
  // after finishing , i will replace the output txt with a doc
  freopen("in.txt", "r", stdin);
  freopen("output_gbn.txt", "w", stdout);
  //--------------------------------------------------------------------------------------

  struct event *eventptr;
  struct msg msg2give;
  struct pkt pkt2give;

  int i, j;
  char c;

  init();
  A_init();
  B_init();

  while (1) {
    eventptr = evlist; /* get next event to simulate */

    if (eventptr == NULL)
      goto terminate;

    evlist = evlist->next; /* remove this event from event list */

    if (evlist != NULL)
      evlist->prev = NULL;

    if (TRACE >= 2) {
      printf("\nEVENT time: %f,", eventptr->evtime);
      printf("  type: %d", eventptr->evtype);
      if (eventptr->evtype == 0)
        printf(", timerinterrupt  ");
      else if (eventptr->evtype == 1)
        printf(", fromlayer5 ");
      else
        printf(", fromlayer3 ");
      printf(" entity: %d\n", eventptr->eventity);
    }

    time = eventptr->evtime; /* update time to next event time */
    if (eventptr->evtype == FROM_LAYER5) {
      if (nsim < nsimmax) {
        if (nsim + 1 < nsimmax)
          generate_next_arrival(); /* set up future arrival */

        /* fill in msg to give with string of same letter */
        j = nsim % 26;

        for (i = 0; i < 20; i++)
          msg2give.data[i] = 97 + j;

        msg2give.data[19] = 0;

        if (TRACE > 2) {
          printf("          MAINLOOP: data given to student: ");
          for (i = 0; i < 20; i++)
            printf("%c", msg2give.data[i]);
          printf("\n");
        }

        nsim++;

        if (eventptr->eventity == A)
          A_output(msg2give);
        else
          B_output(msg2give);
      }
    } else if (eventptr->evtype == FROM_LAYER3) {
      pkt2give.seqnum = eventptr->pktptr->seqnum;
      pkt2give.acknum = eventptr->pktptr->acknum;
      pkt2give.checksum = eventptr->pktptr->checksum;
      for (i = 0; i < 20; i++)
        pkt2give.payload[i] = eventptr->pktptr->payload[i];
      if (eventptr->eventity == A) /* deliver packet by calling */
        A_input(pkt2give); /* appropriate entity */
      else
        B_input(pkt2give);
      free(eventptr->pktptr); /* free the memory for packet */
    } else if (eventptr->evtype == TIMER_INTERRUPT) {
      if (eventptr->eventity == A)
        A_timerinterrupt();
      else
        B_timerinterrupt();
    } else {
      printf("INTERNAL PANIC: unknown event type \n");
    }
    free(eventptr);
  }

  terminate:
  printf(
      " Simulator terminated at time %f\n after sending %d msgs from layer5\n",
      time, nsim);
}

void init() /* initialize the simulator */
{
  int i;
  float sum, avg;
  float jimsrand();

  printf("-----  Stop and Wait Network Simulator Version 1.1 -------- \n\n");
  printf("Enter the number of messages to simulate: ");
  scanf("%d", &nsimmax);
  printf("Enter  packet loss probability [enter 0.0 for no loss]:");
  scanf("%f", &lossprob);
  printf("Enter packet corruption probability [0.0 for no corruption]:");
  scanf("%f", &corruptprob);
  printf("Enter average time between messages from sender's layer5 [ > 0.0]:");
  scanf("%f", &lambda);
  printf("Enter TRACE:");
  scanf("%d", &TRACE);

  srand(9999); /* init random number generator */
  sum = 0.0;   /* test random number generator for students */
  for (i = 0; i < 1000; i++)
    sum = sum + jimsrand(); /* jimsrand() should be uniform in [0,1] */
  avg = sum / 1000.0;
  if (avg < 0.25 || avg > 0.75) {
    printf("It is likely that random number generation on your machine\n");
    printf("is different from what this emulator expects.  Please take\n");
    printf("a look at the routine jimsrand() in the emulator code. Sorry. \n");
    exit(1);
  }

  ntolayer3 = 0;
  nlost = 0;
  ncorrupt = 0;

  time = 0.0;              /* initialize time to 0.0 */
  generate_next_arrival(); /* initialize event list */
}

/****************************************************************************/
/* jimsrand(): return a float in range [0,1].  The routine below is used to */
/* isolate all random number generation in one location.  We assume that the*/
/* system-supplied rand() function return an int in therange [0,mmm]        */
/****************************************************************************/
float jimsrand(void) {
  double mmm = RAND_MAX;
  float x;                 /* individual students may need to change mmm */
  x = rand() / mmm;        /* x should be uniform in [0,1] */
  return (x);
}

/********************* EVENT HANDLINE ROUTINES *******/
/*  The next set of routines handle the event list   */
/*****************************************************/

void generate_next_arrival(void) {
  double x, log(), ceil();
  struct event *evptr;
  float ttime;
  int tempint;

  if (TRACE > 2)
    printf("          GENERATE NEXT ARRIVAL: creating new arrival\n");

  x = lambda * jimsrand() * 2; /* x is uniform on [0,2*lambda] */
  /* having mean of lambda        */
  evptr = (struct event *) malloc(sizeof(struct event));
  evptr->evtime = time + x;
  evptr->evtype = FROM_LAYER5;
  if (BIDIRECTIONAL && (jimsrand() > 0.5))
    evptr->eventity = B;
  else
    evptr->eventity = A;
  insertevent(evptr);
}

void insertevent(struct event *p) {
  struct event *q, *qold;

  if (TRACE > 2) {
    printf("            INSERTEVENT: time is %lf\n", time);
    printf("            INSERTEVENT: future time will be %lf\n", p->evtime);
  }
  q = evlist;      /* q points to header of list in which p struct inserted */
  if (q == NULL)   /* list is empty */
  {
    evlist = p;
    p->next = NULL;
    p->prev = NULL;
  } else {
    for (qold = q; q != NULL && p->evtime > q->evtime; q = q->next)
      qold = q;
    if (q == NULL)   /* end of list */
    {
      qold->next = p;
      p->prev = qold;
      p->next = NULL;
    } else if (q == evlist)     /* front of list */
    {
      p->next = evlist;
      p->prev = NULL;
      p->next->prev = p;
      evlist = p;
    } else     /* middle of list */
    {
      p->next = q;
      p->prev = q->prev;
      q->prev->next = p;
      q->prev = p;
    }
  }
}

void printevlist(void) {
  struct event *q;
  int i;
  printf("--------------\nEvent List Follows:\n");
  for (q = evlist; q != NULL; q = q->next) {
    printf("Event time: %f, type: %d entity: %d\n", q->evtime, q->evtype,
           q->eventity);
  }
  printf("--------------\n");
}


//=================================================================================================
/********************** Student-callable ROUTINES ***********************/
//=================================================================================================
//called by students routine to cancel a previously-started timer

//A or B is trying to stop timer
void stoptimer(int AorB) {
  struct event *q, *qold;

  if (TRACE > 2)
    printf("          STOP TIMER: stopping timer at %f\n", time);
  /* for (q=evlist; q!=NULL && q->next!=NULL; q = q->next)  */
  for (q = evlist; q != NULL; q = q->next)
    if ((q->evtype == TIMER_INTERRUPT && q->eventity == AorB)) {
      /* remove this event */
      if (q->next == NULL && q->prev == NULL)
        evlist = NULL;          /* remove first and only event on list */
      else if (q->next == NULL) /* end of list - there is one in front */
        q->prev->next = NULL;
      else if (q == evlist)   /* front of list - there must be event after */
      {
        q->next->prev = NULL;
        evlist = q->next;
      } else     /* middle of list */
      {
        q->next->prev = q->prev;
        q->prev->next = q->next;
      }
      free(q);
      return;
    }
  printf("Warning: unable to cancel your timer. It wasn't running.\n");
}

//A or B is trying to start timer
void starttimer(int AorB, float increment) {
  struct event *q;
  struct event *evptr;

  if (TRACE > 2)
    printf("          START TIMER: starting timer at %f\n", time);
  /* be nice: check to see if timer is already started, if so, then  warn */
  /* for (q=evlist; q!=NULL && q->next!=NULL; q = q->next)  */
  for (q = evlist; q != NULL; q = q->next)
    if ((q->evtype == TIMER_INTERRUPT && q->eventity == AorB)) {
      printf("Warning: attempt to start a timer that is already started\n");
      return;
    }

  /* create future event for when timer goes off */
  evptr = (struct event *) malloc(sizeof(struct event));
  evptr->evtime = time + increment;
  evptr->evtype = TIMER_INTERRUPT;
  evptr->eventity = AorB;
  insertevent(evptr);
}

//TOLAYER3
void tolayer3(int AorB, struct pkt packet) {
  struct pkt *mypktptr;
  struct event *evptr, *q;
  float lastime, x;
  int i;

  ntolayer3++;

  /* simulate losses: */
  if (jimsrand() < lossprob) {
    nlost++;
    if (TRACE > 0)
      printf("          TOLAYER3: packet being lost\n");
    return;
  }

  /* make a copy of the packet student just gave me since he/she may decide */
  /* to do something with the packet after we return back to him/her */
  mypktptr = (struct pkt *) malloc(sizeof(struct pkt));
  mypktptr->seqnum = packet.seqnum;
  mypktptr->acknum = packet.acknum;
  mypktptr->checksum = packet.checksum;
  for (i = 0; i < 20; i++)
    mypktptr->payload[i] = packet.payload[i];
  if (TRACE > 2) {
    printf("          TOLAYER3: seq: %d, ack %d, check: %d ", mypktptr->seqnum,
           mypktptr->acknum, mypktptr->checksum);
    for (i = 0; i < 20; i++)
      printf("%c", mypktptr->payload[i]);
    printf("\n");
  }

  /* create future event for arrival of packet at the other side */
  evptr = (struct event *) malloc(sizeof(struct event));
  evptr->evtype = FROM_LAYER3;      /* packet will pop out from layer3 */
  evptr->eventity = (AorB + 1) % 2; /* event occurs at other entity */
  evptr->pktptr = mypktptr;         /* save ptr to my copy of packet */
  /* finally, compute the arrival time of packet at the other end.
     medium can not reorder, so make sure packet arrives between 1 and 10
     time units after the latest arrival time of packets
     currently in the medium on their way to the destination */
  lastime = time;
  /* for (q=evlist; q!=NULL && q->next!=NULL; q = q->next) */
  for (q = evlist; q != NULL; q = q->next)
    if ((q->evtype == FROM_LAYER3 && q->eventity == evptr->eventity))
      lastime = q->evtime;
  evptr->evtime = lastime + 1 + 9 * jimsrand();

  /* simulate corruption: */
  if (jimsrand() < corruptprob) {
    ncorrupt++;
    if ((x = jimsrand()) < .75)
      mypktptr->payload[0] = 'Z'; /* corrupt payload */
    else if (x < .875)
      mypktptr->seqnum = 999999;
    else
      mypktptr->acknum = 999999;
    if (TRACE > 0)
      printf("          TOLAYER3: packet being corrupted\n");
  }

  if (TRACE > 2)
    printf("          TOLAYER3: scheduling arrival on other side\n");
  insertevent(evptr);
}

//TOLAYER5
void tolayer5(int AorB, char datasent[20]) {
  int i;
  if (TRACE > 2) {
    printf("          TOLAYER5: data received: ");
    for (i = 0; i < 20; i++)
      printf("%c", datasent[i]);
    printf("\n");
  }
}
//=================================================