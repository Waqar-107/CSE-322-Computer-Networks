/***from dust i have come, dust i will be***/

#include<bits/stdc++.h>
#include <windows.h>

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

#define BLACK 0
#define GREEN 10
#define RED 4
#define CYAN 3
#define WHITE 15

using namespace std;

float probability;
int m, polynomial, R, C;
string str;
vector<string> dataBlock;

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

void init() {
  dataBlock.resize(R);
  for (int i = 0; i < R; i++)
    dataBlock[i] = "";
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
  cout << str << endl << endl;
}

void makeDataBlock() {
  R = str.length() / m;
  C = m;

  //initialize the datablock
  init();

  int len = str.length(), idx = 0;
  for (int i = 0; i < len; i++) {
    dataBlock[idx] += (toBinary(str[i]));

    if ((i + 1) % C == 0)
      idx++;
  }

  pfs("Data Block <ascii code of m char per row>\n");
  for (int i = 0; i < R; i++) {
    cout << dataBlock[i] << endl;
  }

  nl;
}

int calcCheckBitQuantity() {
  int p = 1, x = 8 * m + 1;
  for (int i = 0;; i++) {
    if (x <= p)
      return i;

    p *= 2;
  }
}

void addCheckBits() {
  int i, j, k;
  int len, cnt;
  int r = calcCheckBitQuantity();

  string str;

  for (i = 0; i < R; i++) {
    cnt = 0;
    len = dataBlock[i].length();

    //count the number of 1's
    for (j = 0; j < len; j++) {
      if (dataBlock[i][j] == '1')cnt++;
    }

    //total len
    str.resize(r + len);
    for (j = 0; j < len + r; j++)
      str[j] = ' ';

    //making a odd parity
    //if number of 1 is even then checkbits would be one 1, and (r-1) 0's
    //else there will be r 0's
    if (cnt % 2 == 0)
      str[0] = '1';
    else
      str[0] = '0';

    //fill r - 1 0's now
    //check bits will be in position of power of 2, i.e (1 2 4 8 16...)
    k = 2;
    for (j = 1; j <= r - 1; j++)
      str[k - 1] = '0', k *= 2;

    //fill the data
    k = 0;
    for (j = 0; j < len; j++) {
      while (str[k] != ' ')
        k++;

      str[k] = dataBlock[i][j];
    }

    dataBlock[i] = str;
  }

  len = dataBlock[0].length();
  for (i = 0; i < R; i++) {
    k = 1;
    for (j = 1; j <= len; j++) {
      if (k == j){
        SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), GREEN);
        cout<<dataBlock[i][j];
        SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), WHITE);
        k *= 2;
      }

      cout << dataBlock[i][j];
    }

    cout << endl;
  }
}

int main() {

  freopen("in.txt", "r", stdin);

  //take input
  input();

  //make data block
  makeDataBlock();

  //add check bits
  addCheckBits();

  return 0;
}

//http://www.cplusplus.com/forum/beginner/54360/