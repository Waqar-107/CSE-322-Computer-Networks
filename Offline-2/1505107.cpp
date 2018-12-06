/*** from dust i have come, dust i will be ***/

#include<bits/stdc++.h>
#include<arpa/inet.h>
#include<pthread.h>
#include<semaphore.h>
#include<sys/socket.h>
#include<unistd.h>

#define dbg printf("in\n")
#define nl printf("\n")
#define inf 1000000000

using namespace std;

struct route
{
    string next_hop;
    int cost;

    route() {}
    route(string next_hop, int cost)
    {
        this->next_hop = next_hop;
        this->cost = cost;
    }
};

string myIP;
map<string,route> routingTable;
set<string> adj;

int sockfd, bind_flag;
int bytes_received;
socklen_t addrlen;

struct sockaddr_in client_address;
struct sockaddr_in senders_address;
struct sockaddr_in serve;

void init()
{
    client_address.sin_family = AF_INET;
    client_address.sin_port = htons(4747);
    inet_pton(AF_INET, myIP.c_str(), &client_address.sin_addr);

    serve.sin_family = AF_INET;
    serve.sin_port = htons(4747);

    sockfd = socket(AF_INET, SOCK_DGRAM, 0);
    bind_flag = bind(sockfd, (struct sockaddr*) &client_address, sizeof(sockaddr_in));

    cout << "\n---------------------------------------\n";
    if(!bind_flag)
        cout << "connected!!!\n";
    else {
        cout << "connection error\n";
        exit(0);
    }
    cout << "---------------------------------------\n\n";
}

void showRoutingTable()
{
    printf("destination        next hop        cost\n");
    printf("-----------        --------        ----\n");

    auto itr = routingTable.begin();
    while(itr != routingTable.end())
    {
        cout << itr->first <<"        "<< itr->second.next_hop << "        " << itr->second.cost << endl;
        itr++;
    }
}

string toString(int n)
{
    string str = "";

    if(!n) return "0";

    while(n)
    {
        str.push_back(n % 10 + '0');
        n /= 10;
    }

    reverse(str.begin(), str.end());
    return str;
}

//------------------------------------------------------------------------
//thread for sending and updating
sem_t readyToSend;

void *sendTable(void *arg)
{
	char buffer2[1024];

    while(true)
    {
        sem_wait(&readyToSend);
        for(string s : adj)
        {
            inet_pton(AF_INET, s.c_str(), &client_address.sin_addr);

            memcpy(&buffer2, &routingTable, sizeof(routingTable));
            sendto(sockfd, buffer2, 1024, 0, (struct sockaddr*) &serve, sizeof(sockaddr_in));
        }
    }
}
//------------------------------------------------------------------------

int main(int argc, char *argv[])
{
    int i, j, k;
    int w;


    string u, v, line;
    vector<int> vec;


    char *in = argv[1];
    for(i = 0; i< strlen(in); i++)
        myIP.push_back(in[i]);


    pthread_t sender;
    sem_init(&readyToSend, 0, 0);
    pthread_create(&sender, NULL, sendTable, NULL);


    //--------------------------------------------------------------------
    //read the file and update the routing table
    ifstream infile(argv[2]);
    while(infile >> u >> v >> w)
    {
        //cout<<u.length()<<" "<<v.length()<<" "<<w<<" "<<myIP.length()<<endl;
        if(u == myIP)
            routingTable[v] = route(v, w), adj.insert(v);

        else if(v == myIP)
            routingTable[u] = route(u, w), adj.insert(u);

        else
        {
            if(adj.find(u) != adj.end()) {}
            else
                routingTable[u] = route("     -     ", inf);

            if(adj.find(v) != adj.end()) {}
            else
                routingTable[v] = route("     -     ", inf);
        }
    }

    //initial routing table
    showRoutingTable();
    //--------------------------------------------------------------------


    //--------------------------------------------------------------------
    //initialize receive mode
    init();

    while(true)
    {
        char buffer[1024];
        bytes_received = recvfrom(sockfd, buffer, 1024, 0, (struct sockaddr*) &senders_address, &addrlen);

		//printf("[%s:%d]: %s\n", inet_ntoa(client_address.sin_addr), ntohs(client_address.sin_port), buffer);
        if(bytes_received != -1)
        {
            string cmd(buffer);
            //cout<<cmd<<endl;

            //show the routing table
            if(cmd.find("show") != string::npos)
                showRoutingTable();

            //exchange routing table
            else if(cmd.find("clk") != string::npos)
            {
                sem_post(&readyToSend);

            }

            else if(cmd.find("cost") != string::npos)
            {
                vec.clear();
                for(i = 4; i < bytes_received; i++)
                {
                    k = buffer[i];
                    if(k < 0)
                        k += 256;

                    vec.push_back(k);
                }

                u = toString(vec[0]) + "." + toString(vec[1]) + "." + toString(vec[2]) + "." + toString(vec[3]);
                v = toString(vec[4]) + "." + toString(vec[5]) + "." + toString(vec[6]) + "." + toString(vec[7]);
                w = vec[8];

                if(u == myIP)
                    routingTable[v].cost = w;
                else
                    routingTable[u].cost = w;
            }

            else if(cmd.find("send") != string::npos)
            {
                vec.clear();
                for(i = 4; i < bytes_received; i++)
                {
                    k = buffer[i];
                    if(k < 0)
                        k += 256;

                    vec.push_back(k);
                }

                u = toString(vec[0]) + "." + toString(vec[1]) + "." + toString(vec[2]) + "." + toString(vec[3]);
                v = toString(vec[4]) + "." + toString(vec[5]) + "." + toString(vec[6]) + "." + toString(vec[7]);
                k = vec[8];

                cout<<"u: "<<u<<". v: "<<v<<" mip: "<<myIP<<endl;

                //destination reached
                string temp = "";
                if(v == myIP)
                {
                    for(i = 9; i <= vec.size(); i++)
                        temp.push_back((char)vec[i]);

                    cout << u << " sent to " <<v <<" : "<< temp << endl;
                }



                else
                {
                    //cout<<"u: "<<u<<". v: "<<v<<". msg: "<<temp<<endl;
                    if(routingTable[v].next_hop != "-")
                    {
                        inet_pton(AF_INET, routingTable[v].next_hop.c_str(), &client_address.sin_addr);
                        sendto(sockfd, buffer, 1024, 0, (struct sockaddr*) &serve, sizeof(sockaddr_in));
                    }

                    else
                        cout << "router " << v<< " seems uncreachable at the moment\n";
                }

                memset(buffer, 0, sizeof(buffer));
            }
        }

        else
            cout << "-1 received : ", printf("%s\n", buffer);
    }

    //--------------------------------------------------------------------
    //--------------------------------------------------------------------

    return 0;
}
