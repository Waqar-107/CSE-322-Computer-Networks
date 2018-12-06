#include <cstdio>

#include <arpa/inet.h>
#include <sys/socket.h>
#include <unistd.h>
#include<bits/stdc++.h>

using namespace std;

int main(){

	int sockfd; 
	int bind_flag;
	int bytes_received;
	socklen_t addrlen;
	char buffer[1024];
	struct sockaddr_in server_address;
	struct sockaddr_in client_address;

	server_address.sin_family = AF_INET;
	server_address.sin_port = htons(4747);
	server_address.sin_addr.s_addr = inet_addr("192.168.0.100");	//change inet here

	sockfd = socket(AF_INET, SOCK_DGRAM, 0);
	bind_flag = bind(sockfd, (struct sockaddr*) &server_address, sizeof(sockaddr_in));

	printf("server started\n");
pair<int,int> p;
	while(true){
		bytes_received = recvfrom(sockfd, buffer, 1024, 0, (struct sockaddr*) &client_address, &addrlen);
		//printf("[%s:%d]: %s\n", inet_ntoa(client_address.sin_addr), ntohs(client_address.sin_port), buffer);
memcpy(&p,&buffer,1024);	
printf("receivedd: %d %d\n", p.first,p.second);
	}

	return 0;

}
