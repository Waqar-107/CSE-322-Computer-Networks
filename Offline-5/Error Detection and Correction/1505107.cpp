/***from dust i have come, dust i will be***/

#include<bits/stdc++.h>
#include <windows.h>

#define dbg printf("in\n");
#define nl printf("\n");

#define sf(n) scanf("%d", &n)
#define pfs(s) printf("%s",s)

#define pb push_back

#define BLACK 0
#define GREEN 10
#define RED 4
#define CYAN 3
#define WHITE 15

using namespace std;

float probability;
int m, R, C;
string str, polynomial;
vector<string> dataBlock;
string columnMajor;

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
  cin >> polynomial;

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
  int i, j, k, l;
  int len, cnt;
  int r = calcCheckBitQuantity();

  string str, tmp;

  for (i = 0; i < R; i++) {
    cnt = 0;
    len = dataBlock[i].length();

    //total len
    str.resize(r + len);
    for (j = 0; j < len + r; j++)
      str[j] = ' ';

    //mark the parity bits
    k = 1;
    for (j = 1; j <= r; j++)
      str[k - 1] = '#', k *= 2;

    //fill the data
    k = 0;
    for (j = 0; j < len; j++) {
      while (str[k] != ' ')
        k++;

      str[k] = dataBlock[i][j];
    }

    //determine the parity
    len += r;
    l = 1;
    for (j = 1; j <= r; j++) {
      cnt = 0;
      for (k = j + 1; k <= len; k++) {
        tmp = toBinary(k);
        reverse(tmp.begin(), tmp.end());

        if (tmp[j - 1] == '1' && str[k - 1] == '1')cnt++;
      }

      //go for even parity
      if (cnt % 2)
        str[l - 1] = '1';
      else
        str[l - 1] = '0';

      l *= 2;
    }

    dataBlock[i] = str;
  }

  //print
  pfs("Data Block After Adding Check Bits\n");
  len = dataBlock[0].length();
  for (i = 0; i < R; i++) {
    k = 1;
    for (j = 1; j <= len; j++) {
      if (k == j) {
        SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), GREEN);
        cout << dataBlock[i][j - 1];
        SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), WHITE);
        k *= 2;
      } else
        cout << dataBlock[i][j - 1];
    }

    cout << endl;
  }

  nl;
}

void serializeInColumnMajor() {
  columnMajor = "";
  C *= 8;
  for (int i = 0; i < C; i++) {
    for (int j = 0; j < R; j++)
      columnMajor.pb(dataBlock[j][i]);
  }

  pfs("Data-Bits After Column-Wise Serialization\n");
  cout << columnMajor << endl << endl;
}

void calculateCRC() {
  string tmp, tmp2;
  string temp = columnMajor;

  int len = polynomial.length();

  //add k-1 0's at the end
  //k=len of polynomial
  for (int i = 1; i < len; i++)
    temp.pb('0');

  //modulo-2 binary division
  //instead of subtraction we do xor
  //extract len(polynomial) chars
  tmp = "";
  for (int i = 0; i < len; i++)
    tmp.pb(temp[i]);

  int k = len, idx;
  while (tmp.length() == len) {
    //xor
    for (int i = 0; i < len; i++)
      tmp[i] = ((polynomial[i] - '0') ^ (tmp[i] - '0')) + '0';

    idx = -1;
    for (int i = 0; i < len; i++) {
      if (tmp[i] == '1') {
        idx = i;
        break;
      }
    }

    //if idx == -1 then the whole thing is 0
    if (idx != -1) {
      tmp2 = "";
      for (int i = idx; i < len; i++)
        tmp2.pb(tmp[i]);

      tmp = tmp2;
    } else
      tmp = "";

    while (k < temp.length() && tmp.length() < len)
      tmp.pb(temp[k++]);
  }
cout<<"rem "<<tmp<<endl;
  //make the remainder length == n - 1
  reverse(tmp.begin(), tmp.end());
  while (tmp.length() < len - 1)
    tmp.pb('0');
  reverse(tmp.begin(), tmp.end());

  //now tmp has the remainder that we shall concatenate
  //first print then concatenate
  pfs("Data Bits After Appending CRC Checksum <sent frame>\n");
  cout << columnMajor;

  SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), CYAN);
  cout << tmp << endl << endl;
  SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), WHITE);

  columnMajor += tmp;
}

int main() {

  freopen("in.txt", "r", stdin);

  //take input
  input();

  //make data block
  makeDataBlock();

  //add check bits
  addCheckBits();

  //serialize in column-major order
  serializeInColumnMajor();

  //calculate crc checksum
  calculateCRC();

  return 0;
}

//http://www.cplusplus.com/forum/beginner/54360/
//https://www.geeksforgeeks.org/computer-network-hamming-code
//https://www.youtube.com/watch?v=6gbkoFciryA