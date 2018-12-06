#include<bits/stdc++.h>

#define dbg printf("in\n")
#define nl printf("\n")
#define inf 1000000000

using namespace std;

struct route
{
    string next_hop;
    int cost;

    route(){}
    route(string next_hop, int cost){
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

    string myIP;
    string u, v, line;

    char *in = argv[1];
    for(i = 0; i< strlen(in); i++)
        myIP.push_back(in[i]);



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
            if(adj.find(u) != adj.end()){}
            else
                routingTable[u] = route("     -     ", inf);

            if(adj.find(v) != adj.end()){}
            else
                routingTable[v] = route("     -     ", inf);
        }
    }

    //initial routing table
    showRoutingTable();

    return 0;
}
