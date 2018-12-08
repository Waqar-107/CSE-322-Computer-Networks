/*** from dust i have come, dust i will be ***/

#include<bits/stdc++.h>
#include<arpa/inet.h>
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

int currentCLK;
string myIP;
map<string, route> routingTable;
map<string, route> tempTable;
map<string, bool> downSent;
set<string> adj;
map<string, int > neighborCost;
map<string, int> lastCLK;
vector<string> active, inactive;

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
    else
    {
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

int toInt(string s)
{
    int n = 0, k = 1;
    for(int i = s.length() - 1 ; i >= 0; i--)
        n += (s[i] - 48) * k, k *= 10;

    return n;
}

//------------------------------------------------------------------------
//send table
void sendTable()
{
    char buffer2[1024];
    string str = "";

    auto itr = routingTable.begin();
    while(itr != routingTable.end())
    {
        if(itr->second.next_hop != "     -     ")
            str += myIP + "|" + itr->first + "|" + itr->second.next_hop + "|" + toString(itr->second.cost) + "_";

        itr++;
    }

    strcpy(buffer2, str.c_str());
    //printf("sending %s\n", buffer2);
    for(string s : adj)
    {
        serve.sin_addr.s_addr = inet_addr(s.c_str());
        sendto(sockfd, buffer2, 1024, 0, (struct sockaddr*) &serve, sizeof(sockaddr_in));
    }
}

void sendDown()
{
    string str = "down_" + myIP + "_";

    for(string s : inactive)
        str += s + "_";

    str += "#";
    for(string s : active)
        str += s + "|" + routingTable[s].next_hop + "|" + toString(routingTable[s].cost) + "_";

    char buffer2[1024];
    strcpy(buffer2, str.c_str());
    //printf("sending %s\n", buffer2);
    for(string s : active)
    {
        serve.sin_addr.s_addr = inet_addr(s.c_str());
        sendto(sockfd, buffer2, 1024, 0, (struct sockaddr*) &serve, sizeof(sockaddr_in));
    }
}
//------------------------------------------------------------------------

int main(int argc, char *argv[])
{
    int i, j, k;
    int w, currentCLK = 0;


    string u, v, line;
    vector<int> vec;


    char *in = argv[1];
    for(i = 0; i< strlen(in); i++)
        myIP.push_back(in[i]);

    //--------------------------------------------------------------------
    //read the file and update the routing table
    ifstream infile(argv[2]);
    while(infile >> u >> v >> w)
    {
        //cout<<u.length()<<" "<<v.length()<<" "<<w<<" "<<myIP.length()<<endl;
        if(u == myIP)
            routingTable[v] = route(v, w), adj.insert(v), neighborCost[v] = w;

        else if(v == myIP)
            routingTable[u] = route(u, w), adj.insert(u), neighborCost[u] = w;

        else
        {
            if(adj.find(u) != adj.end()) {}
            else
                routingTable[u] = route("     -     ", inf);

            if(adj.find(v) != adj.end()) {}
            else
                routingTable[v] = route("     -     ", inf);
        }

        lastCLK[u] = -1;
        lastCLK[v] = -1;
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

        //printf("[%s:%d]: %s\n", inet_ntoa(senders_address.sin_addr), ntohs(senders_address.sin_port), buffer);
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
                //cout << cmd << endl;
                currentCLK++;
                sendTable();
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

                //vec[i+1] has len/256, vec[i] has len%256;
                w = vec[9] * 256 + vec[8];

                if(u == myIP)
                {
                    neighborCost[v] = w;

                    //if this was the least path
                    if(routingTable[v].next_hop == v)
                        routingTable[v].cost = w;

                    //there was a different path, but now i want to directly move to my neighbour
                    else if(routingTable[v].cost > w)
                        routingTable[v].cost = w, routingTable[v].next_hop =v;
                }

                else
                {
                    neighborCost[u] = w;

                    //if this was the least path
                    if(routingTable[u].next_hop == u)
                        routingTable[u].cost = w;

                    //there was a different path, but now i want to directly move to my neighbour
                    else if(routingTable[u].cost > w)
                        routingTable[u].cost = w, routingTable[u].next_hop = u;
                }
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

                //vec[i+1] has len/256, vec[i] has len%256;
                k = vec[9] * 256 + vec[8];

                //cout<<"u: "<<u<<". v: "<<v<<" mip: "<<myIP<<endl;

                //destination reached
                string temp = "";
                if(v == myIP)
                {
                    for(i = 9; i <= k + 9; i++)
                        temp.push_back((char)vec[i]);

                    cout << u << " sent packet: " << temp <<endl;
                }


                else
                {
                    //cout<<"u: "<<u<<". v: "<<v<<". msg: "<<temp<<endl;
                    if(routingTable[v].cost < inf)
                    {
                        cout << "packet forwarded to router-" << routingTable[v].next_hop << endl;
                        serve.sin_addr.s_addr = inet_addr(routingTable[v].next_hop.c_str());
                        sendto(sockfd, buffer, 1024, 0, (struct sockaddr*) &serve, sizeof(sockaddr_in));
                    }

                    else
                        cout << "router " << v << " seems uncreachable at the moment\n";
                }

                memset(buffer, 0, sizeof(buffer));
            }

            else if(cmd.find("down") != string::npos)
            {
                tempTable.clear();

                //let u-v be down and i am in X,
                //then if i go somewhere using u-v edge previously, after 'down' i would not be able reach there
                //so if routerTable[somewhere].next_hop == u and routerTable[u].next_hop == v then set it inf

                set<string> sec;
                string senderIP = "";

                //senders ip
                k = 0;
                for(i = 5; i < strlen(buffer); i++)
                {
                    if(buffer[i] == '_')
                    {
                        k = i + 1;
                        break;
                    }

                    senderIP.push_back(buffer[i]);
                }

                //the edges that are down
                string temp = "";
                while(k < strlen(buffer))
                {
                    if(buffer[k] == '#')
                    {
                        k++;
                        break;
                    }

                    if(buffer[k] == '_')
                    {
                        sec.insert(temp);
                        temp="";
                    }

                    else
                        temp.push_back(buffer[k]);

                    k++;
                }

                //now get the routing table
                vector<string> rcv;
                u ="";
                while(k < strlen(buffer))
                {
                    if(buffer[k] == '_')
                        rcv.push_back(u), u = "";
                    else
                        u.push_back(buffer[k]);

                    k++;
                }

                string nxt="", hop = "";
                for(string s : rcv)
                {
                    k = 0;
                    nxt = "";
                    while(k < s.length())
                    {
                        if(s[k] == '|')
                        {
                            k++;
                            break;
                        }
                        nxt.push_back(s[k]);
                        k++;
                    }

                    hop = "";
                    while(k < s.length())
                    {
                        if(s[k] == '|')
                        {
                            k++;
                            break;
                        }
                        hop.push_back(s[k]);
                        k++;
                    }

                    v = "";
                    while(k < s.length())
                    {
                        if(s[k] == '|')
                        {
                            k++;
                            break;
                        }
                        v.push_back(s[k]);
                        k++;
                    }

                    w = toInt(v);

                    //nxt hop cost
                    tempTable[nxt] = route(hop, w);
                }

                auto itr = routingTable.begin();
                while(itr != routingTable.end())
                {
                    if(routingTable[itr->first].next_hop == senderIP)
                    {
                        //sec has the list of router, that had edge with sender
                        //so if we find the next hop from u, in the list then it is not possible for now to reach
                        if(sec.find(tempTable[itr->first].next_hop) != sec.end())
                        {
                            routingTable[itr->first].next_hop = "     -     ";
                            routingTable[itr->first].cost = inf;
                        }
                    }

                    itr++;
                }

            }

            else
            {
                //case-3 check if it is reasonable to go to neighbours directly
                for(string s : adj)
                {
                    if(!downSent[s] && routingTable[s].cost>neighborCost[s])
                    {
                        routingTable[s].cost = neighborCost[s];
                        routingTable[s].next_hop = s;
                    }
                }

                //the routing table is here, so try to update
                //printf("got %s\n", buffer);
                vector<string> rcv;
                u ="";
                for(i = 0 ; i < strlen(buffer); i++)
                {
                    if(buffer[i] == '_')
                        rcv.push_back(u), u = "";
                    else
                        u.push_back(buffer[i]);
                }

                string t2 = "", senderIP = "";
                for(string s : rcv)
                {
                    k = 0;
                    senderIP = "";
                    while(k < s.length())
                    {
                        if(s[k] == '|')
                        {
                            k++;
                            break;
                        }
                        senderIP.push_back(s[k]);
                        k++;
                    }

                    u = "";
                    while(k < s.length())
                    {
                        if(s[k] == '|')
                        {
                            k++;
                            break;
                        }
                        u.push_back(s[k]);
                        k++;
                    }

                    v = "";
                    while(k < s.length())
                    {
                        if(s[k] == '|')
                        {
                            k++;
                            break;
                        }
                        v.push_back(s[k]);
                        k++;
                    }

                    t2 = "";
                    while(k < s.length())
                    {
                        if(s[k] == '|')
                        {
                            k++;
                            break;
                        }
                        t2.push_back(s[k]);
                        k++;
                    }

                    w = toInt(t2);

                    lastCLK[senderIP] = currentCLK;

                    //senderIP u=neighbour of sender, v=hop, cost
                    //cout<<senderIP<<" "<<u<<" "<<cost<<endl;
                    if(u != myIP)
                    {
                        //case 1 - if i went to u through senderIP -> then go through it\
                        the cost of u-senderIP may have changed now that bellman will never get
                        if(routingTable[u].next_hop == senderIP)
                            routingTable[u].cost = routingTable[senderIP].cost + w;

                        //normal bellman ford
                        if(routingTable[u].cost > routingTable[senderIP].cost + w)
                        {
                            //cout<<u<<" i2f "<<routingTable[u].next_hop<<" "<<senderIP<<" "<<routingTable[u].cost<<" "<<(routingTable[senderIP].cost + w)<<endl;
                            routingTable[u].cost = routingTable[senderIP].cost + w;
                            routingTable[u].next_hop = routingTable[senderIP].next_hop;
                            //cout<<myIP<<" "<<u<<" "<<routingTable[u].next_hop<<endl<<endl;
                        }
                    }
                }
            }
        }

        else
            cout << "-1 received : ", printf("%s\n", buffer);

        memset(buffer, 0, sizeof(buffer));

        //----------------------------------------------------------------
        //check for down
        active.clear();
        inactive.clear();

        for(string s : adj)
        {
            if(lastCLK[s] == -1)continue;

            //the edge myIP-s is down
            if(lastCLK[s] != -1 && currentCLK - lastCLK[s] >= 3 && !downSent[s])
            {
                neighborCost[s] = inf;

                auto itr = routingTable.begin();
                while(itr != routingTable.end())
                {
                    if(itr->second.next_hop == s)
                    {
                        routingTable[itr->first].next_hop = "     -     ";
                        routingTable[itr->first].cost = inf;
                    }

                    itr++;
                }

                inactive.push_back(s);
                downSent[s] = true;
                cout<<currentCLK<<" "<<lastCLK[s]<<" "<<myIP<<" "<<s<<" down\n";
            }

            else
                active.push_back(s);
        }

        if(inactive.size())
            sendDown();
        //cout<<active.size()<<" "<<inactive.size()<<endl;
        //-----------------------------------------------------------------
    }

    //--------------------------------------------------------------------

    return 0;
}
