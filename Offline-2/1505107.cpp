/*** from dust i have come, dust i will be ***/

#include<bits/stdc++.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#include <unistd.h>

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

//key would be the destination
map<string,route> routingTable;

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

int main(int argc, char *argv[])
{
    int i, j, k;
    int w;

    string myIP, cmd;
    string u, v, line;

    char *in = argv[1];
    for(i = 0; i< strlen(in); i++)
        myIP.push_back(in[i]);


    //--------------------------------------------------------------------
    //read the file and update the routing table
    ifstream infile(argv[2]);
    set<string> adj;

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
    int sockfd, bind_flag;
    int bytes_received;
	socklen_t addrlen;

    struct sockaddr_in client_address;
    struct sockaddr_in senders_address;

    client_address.sin_family = AF_INET;
    client_address.sin_port = htons(4747);
    inet_pton(AF_INET, myIP.c_str(), &client_address.sin_addr);

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

    while(true)
    {
        char buffer[1024];
        bytes_received = recvfrom(sockfd, buffer, 1024, 0, (struct sockaddr*) &senders_address, &addrlen);

		//printf("[%s:%d]: %s\n", inet_ntoa(client_address.sin_addr), ntohs(client_address.sin_port), buffer);
        if(bytes_received != -1)
        {
            string cmd(buffer);
            cout<<cmd<<endl;

            //show the routing table
            if(cmd.find("show") != string::npos)
                showRoutingTable();
        }
    }

    //--------------------------------------------------------------------
    //--------------------------------------------------------------------
    return 0;
}
