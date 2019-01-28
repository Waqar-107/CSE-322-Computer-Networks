/***from dust i have come, dust i will be***/

#include<bits/stdc++.h>

typedef long long int ll;
typedef unsigned long long int ull;

#define dbg printf("in\n");
#define nl printf("\n");
#define N 250

#define sf(n) scanf("%d", &n)
#define sff(n, m) scanf("%d%d",&n,&m)
#define sfl(n) scanf("%I64d", &n)
#define sffl(n, m) scanf("%I64d%I64d",&n,&m)

#define pf(n) printf("%d",n)
#define pff(n, m) printf("%d %d",n,m)
#define pffl(n, m) printf("%I64d %I64d",n,m)
#define pfl(n) printf("%I64d",n)
#define pfs(s) printf("%s",s)

#define pb push_back
#define pp pair<int,int>

using namespace std;

float probability;
int m, polynomial, R, C;
string str;
vector<vector<string>> dataBlock;

string toBinary(int x) {
  string temp = "";
  while (x) {
    temp.push_back(x % 2 + '0');
    x /= 2;
  }

  while (temp.size() < 8)
    temp.pb('0');

  reverse(temp.begin(), temp.end());

  return temp;
}

void input() {
  pfs("Enter Data String:\n");
  getline(cin, str);

  pfs("Enter Number of Data Bytes in a Row:\n");
  sf(m);

  pfs("Enter Probability <p>:\n");
  scanf("%f", &probability);

  pfs("Enter Generator Polynomial:\n");
  sf(polynomial);

  //add extra char
  while (str.length() % m != 0)
    str.pb('~');

  //data after we add extra '~'
  pfs("Data String After Padding: \n");
  cout << str << endl;
}

void makeDataBlock() {
  R = str.length() / m;
  C = m;

  dataBlock.resize(R);

  int len = str.length(), idx = 0;
  for (int i = 0; i < len; i++) {
    dataBlock[idx].pb(toBinary(str[i]));

    if((i+1)%C==0)
      idx++;
  }

  pfs("Data Block <ascii code of m char per row>\n");
  for(int i =0;i<R;i++)
  {
    for(int j=0;j<C;j++)
      cout<<dataBlock[i][j]<<" ";
    nl;
  }
}

int main() {

  freopen("in.txt", "r", stdin);

  //take input
  input();

  //make data block
  makeDataBlock();


  return 0;
}