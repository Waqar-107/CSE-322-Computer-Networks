/***from dust i have come, dust i will be***/

#include<bits/stdc++.h>
#include <random>
#include <windows.h>

#define dbg printf("in\n");
#define nl printf("\n");

#define sf(n) scanf("%d", &n)
#define pfs(s) printf("%s",s)

#define pb push_back

#define BLACK 0
#define GREEN 10
#define RED 12
#define CYAN 11
#define WHITE 15

using namespace std;

double probability;
int m, R, C;
string str, polynomial, recvStr;
vector<string> dataBlock;
vector<string> dataBlockReceiver;
vector<double> randoms;
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
  dataBlockReceiver.resize(R);

  for (int i = 0; i < R; i++)
    dataBlock[i] = "", dataBlockReceiver[i] = "";
}

int toAscii(string s) {
  int p = 1, sum = 0;
  for (int i = s.length() - 1; i >= 0; i--)
    sum += (s[i] - '0') * p, p *= 2;

  return sum;
}

//===============================================
//1
void input() {
  pfs("Enter Data String:\n");
  getline(cin, str);

  pfs("Enter Number of Data Bytes in a Row:\n");
  sf(m);

  pfs("Enter Probability <p>:\n");
  scanf("%lf", &probability);

  pfs("Enter Generator Polynomial:\n");
  cin >> polynomial;

  //add extra char
  while (str.length() % m != 0)
    str.pb('~');

  //data after we add extra '~'
  pfs("Data String After Padding: \n");
  cout << str << endl << endl;
}
//===============================================


//===============================================
//2
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
//===============================================


//===============================================
//3
int calcCheckBitQuantity() {
  int p = 1, x = 8 * m + 1;
  for (int i = 0;; i++) {
    if (x <= p)
      return i;

    p *= 2;
  }

  return -1;
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
//===============================================


//===============================================
//4
void serializeInColumnMajor() {
  columnMajor = "";
  C = dataBlock[0].length();
  for (int i = 0; i < C; i++) {
    for (int j = 0; j < R; j++)
      columnMajor.pb(dataBlock[j][i]);
  }

  pfs("Data-Bits After Column-Wise Serialization\n");
  cout << columnMajor << endl << endl;
}
//===============================================


//===============================================
//5
//return remainder after module 2 divison
string modulo2Divison(string dividend, string divisor) {
  if (divisor.length() > dividend.length())return dividend;

  int i, j, k;
  int len = divisor.length();

  string rem, tmp;

  //first chunk
  for (i = 0; i < len; i++)
    rem.pb(dividend[i]);

  //divison
  k = len;
  while (rem.length() == divisor.length()) {
    //xor
    for (i = 0; i < len; i++)
      rem[i] = ((rem[i] - '0') ^ (divisor[i] - '0')) + '0';

    //cut-off the leading 0's
    tmp = "";
    for (i = 0; i < len; i++) {
      if (rem[i] == '1') {
        for (j = i; j < len; j++)
          tmp.pb(rem[j]);
        break;
      }
    }

    rem = tmp;

    //make length(rem) == length(divisor)
    while (k < dividend.length() && rem.length() < divisor.length())
      rem.pb(dividend[k++]);
  }

  if (rem.length() == 0)rem = "0";

  return rem;
}

void calculateCRC() {
  string temp = columnMajor, rem;

  int len = polynomial.length();

  //add k-1 0's at the end
  //k = len of polynomial
  for (int i = 1; i < len; i++)
    temp.pb('0');

  //modulo-2 binary division
  rem = modulo2Divison(temp, polynomial);

  //make the remainder length == n - 1
  reverse(rem.begin(), rem.end());
  while (rem.length() < len - 1)
    rem.pb('0');
  reverse(rem.begin(), rem.end());

  //now tmp has the remainder that we shall concatenate
  //first print then concatenate
  pfs("Data Bits After Appending CRC Checksum <sent frame>\n");
  cout << columnMajor;

  SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), CYAN);
  cout << rem << endl << endl;
  SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), WHITE);

  columnMajor += rem;
}
//===============================================


//===============================================
//6
//generate a random uniformly distributed in the range [0-1]
void generateRandomBits(int n) {
  // construct a trivial random generator engine from a time-based seed:
  unsigned seed = chrono::system_clock::now().time_since_epoch().count();
  default_random_engine generator(seed);

  uniform_real_distribution<double> dist(0.0, 1.0);

  for (int i = 0; i < n; i++)
    randoms.pb(dist(generator));
}

void toggleBits() {

  int len = columnMajor.length();
  generateRandomBits(len);

  pfs("Received Frame\n");
  for (int i = 0; i < len; i++) {
    if (randoms[i] <= probability) {
      SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), RED);
      columnMajor[i] = (1 - (columnMajor[i] - '0')) + '0';
      cout << columnMajor[i];
      SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), WHITE);
    } else
      cout << columnMajor[i];
  }

  pfs("\n\n");
}
//===============================================


//===============================================
//7
//verify the received frame
void verifyReceivedFrame() {
  string rem = modulo2Divison(columnMajor, polynomial);

  pfs("Result of CRC Checksum Matching : ");
  if (rem == "0")pfs(" No Error\n\n");
  else
    pfs("Error Detected\n\n");
}
//===============================================


//===============================================
//8
void removeCRC() {
  //remove the checksum
  int len = polynomial.length();
  for (int i = 1; i <= len - 1; i++)
    columnMajor.pop_back();

  //de-serialize
  // error to be done marking
  int k = 0;
  len = columnMajor.length();
  for (int i = 0; i < len; i++) {
    dataBlockReceiver[k++].pb(columnMajor[i]);
    if (k == R)
      k = 0;
  }

  pfs("Data Block After Removing CRC Checksum Bits:\n");
  for (int i = 0; i < R; i++) {
    cout << dataBlockReceiver[i] << endl;
  }

  nl;
}
//===============================================


//===============================================
//9
//eradicate errors and remove check bits
void removeCheckBits() {
  int cnt, p, sum;
  int r = calcCheckBitQuantity();
  int len = dataBlockReceiver[0].length();

  string tmp;

  for (int i = 0; i < R; i++) {
    p = 1, sum = 0;
    for (int j = 1; j <= r; j++) {
      cnt = 0;
      for (int k = 1; k <= len; k++) {
        tmp = toBinary(k);
        if (tmp[j - 1] == '1' && dataBlockReceiver[i][k - 1] == '1')cnt++;
      }

      cnt = cnt % 2;
      sum += p * cnt, p *= 2;
    }

    //sum'th bit is corrupted where sum > 0
    if (sum)
      dataBlockReceiver[i][sum - 1] = !(dataBlockReceiver[i][sum - 1] - '0') + '0';

    //remove the bits where check bits were placed
    p = 1;
    tmp.clear();
    for (int j = 1; j <= len; j++) {
      if (j == p) {
        p *= 2;
        continue;
      }

      tmp.pb(dataBlockReceiver[i][j-1]);
    }

    dataBlockReceiver[i] = tmp;
  }

  pfs("Data Block After Removing Check Bits\n");
  for (int i = 0; i < R; i++)
    cout << dataBlockReceiver[i] << endl;

  nl;
}
//===============================================


//===============================================
//10
//decode the real data
void decodeData() {
  string tmp;
  int len = dataBlockReceiver[0].length();

  for (int i = 0; i < R; i++) {
    for (int j = 0; j < len; j++) {
      tmp.pb(dataBlockReceiver[i][j]);
      if (tmp.length() == 8) {
        recvStr.pb((char) toAscii(tmp)), tmp.clear();
      }
    }
  }

  pfs("Output Frame: ");
  cout << recvStr << endl;
}
//===============================================

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

  //toggle the bits
  toggleBits();

  //verify correctness
  verifyReceivedFrame();

  //remove checksum and deserialize
  removeCRC();

  //remove the check bits and error
  removeCheckBits();

  //decode the data
  decodeData();

  return 0;
}

///color change
//http://www.cplusplus.com/forum/beginner/54360/

///hamming and parity
//https://www.geeksforgeeks.org/computer-network-hamming-code

///CRC:
//https://www.geeksforgeeks.org/modulo-2-binary-division
//https://www.youtube.com/watch?v=6gbkoFciryA

///random number
//https://stackoverflow.com/questions/288739/generate-random-numbers-uniformly-over-an-entire-range
//http://www.cplusplus.com/reference/random/uniform_real_distribution/uniform_real_distribution/