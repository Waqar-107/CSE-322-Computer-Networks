BEGIN {
	max_node = 2000;
	nSentPackets = 0.0 ;		
	nReceivedPackets = 0.0 ;
	rTotalDelay = 0.0 ;
	max_pckt = 10000;
	
	idHighestPacket = 0;
	idLowestPacket = 100000;
	rStartTime = 10000.0;
	rEndTime = 0.0;
	nReceivedBytes = 0;

	nDropPackets = 0.0;

	temp = 0;

	for (i=0; i<max_node; i++) {
		byteReceivedByNode[i] = 0;
	}

	total_retransmit = 0;
	for (i=0; i<max_pckt; i++) {
		retransmit[i] = 0;		
	}

	#hard-code
	sentBy_0 = 0;
	receivedBy_8 = 0;
}

{
	#then this a wired record, for the wireless it has "---" in $5
	if ( $5 == "tcp" ) {
		event = $1; rTime = $2; src_node = $3;
		dest_node = $4; packetType = $5; packetSZ = $6;
		flow_id = $8; src_addr = $9;
		dest_addr = $10; seq_no = $11; packetID = $12;

		if(packetType == "tcp")
		{
			if(packetID > idHighestPacket)idHighestPacket = packetID;
			if(packetID < idLowestPacket)idLowestPacket = packetID;

			if(rTime < rStartTime)rStartTime = rTime;
			if(rTime > rStartTime)rStartTime = rTime; 

			sub(/^_*/, "", node);
			sub(/_*$/, "", node);


			if ( event == "r" && int(dest_addr) == int(dest_node) && packetSZ == "1040")
			{
				nReceivedPackets += 1 ;		
				nReceivedBytes += packetSZ;

				potential_source = int(src_addr)
				rReceivedTime[packetID] = rTime ;
				rDelay[packetID] = rReceivedTime[packetID] - rSentTime[packetID];
				rTotalDelay += rDelay[packetID]; 
				
				byteReceivedByNode[int(dest)] = packetSZ;
			}

			if(event == "d" && packetSZ == "1040")nDropPackets++;

			if(event == "+" && packetSZ == "1040")
			{
				if(int(src_node) == int(src_addr)){
					nSentPackets++;
					rSentTime[packetID] = rTime;

					if(int(src_node) == "0")sentBy_0++;
				}
			}

		}
	}

	else {
		event = $1 ;			receiveTime = $2 ;
		node = $3 ;
		receiveAgt = $4 ;		packetID = $6 ;
		messageType = $7 ;		nBytes = $8;

		energy = $13;			total_energy = $14;
		
		idle_energy_consumption = $16;	
		sleep_energy_consumption = $18; 
		transmit_energy_consumption = $20;	
		receive_energy_consumption = $22; 
		
		num_retransmit = $30;
		
		sub(/^_*/, "", node);
		sub(/_*$/, "", node);

		if(receiveAgt == "AGT" && messageType == "tcp") {
			if(packetID > idHighestPacket) idHighestPacket = packetID;
			if(packetID < idLowestPacket) idLowestPacket = packetID;

			if(receiveTime > rEndTime) rEndTime = receiveTime;
			if(receiveTime < rStartTime) rStartTime = receiveTime;

			if(event == "s") {
				nSentPackets++;
				rSentTime[packetID] = receiveTime;
				#printf("packet no- %d sent at %d\n",packetID,receiveTime);
			}

			if(event == "r" && packetID >= idLowestPacket) {
				nReceivedPackets++;
				nReceivedBytes += nBytes;
				byteReceivedByNode[node] += nBytes;

				if(node == "8")receivedBy_8++;

				#printf("received %15.0f bytes\n", nBytes);
				
				rReceivedTime[packetID] = receiveTime;
				rDelay[packetID] = rReceivedTime[packetID] - rSentTime[packetID];
				rTotalDelay += rDelay[packetID]

				#printf("%15.5f\n",rDelay[packetID]);
			}
		}
		
		#energy of nodes
		if(energy == "[energy") {
			energy_consumption[node] = (idle_energy_consumption + sleep_energy_consumption + transmit_energy_consumption + receive_energy_consumption);
			#printf("%d %15.5f\n", node, energy_consumption[node]);
		}

		if(messageType == "tcp") retransmit[packetID] = num_retransmit;

		if(event == "D" && messageType == "tcp") {
			dropPackets++;
			if(receiveTime > rEndTime) rEndTime = receiveTime;
			if(receiveTime < rStartTime) rStartTime = receiveTime;
		}
	}



}

END {

	printf("\n\n");
	#--------------------------------------------------------------------
	rTime = rEndTime - rStartTime ;
	rThroughput = nReceivedBytes*8 / rTime;
	rPacketDeliveryRatio = nReceivedPackets / nSentPackets * 100 ;
	rPacketDropRatio = nDropPackets / nSentPackets * 100;
	#--------------------------------------------------------------------

	#--------------------------------------------------------------------
	for (i=0; i<max_pckt; i++)total_retransmit += retransmit[i] ;
	#--------------------------------------------------------------------
	
	#---------------------------------------------------------------------
	printf("total packets sent: %d\n",nSentPackets);
	printf("total packets received: %d\n", nReceivedPackets);
	printf("packets dropped: %d\n",dropPackets);
	#---------------------------------------------------------------------

	printf("throughput: %f bps\n", rThroughput);
	printf("packet delivery ratio: %f\n", rPacketDeliveryRatio);
	printf("packet drop ratio: %f\n",rPacketDropRatio);

	printf("sent by node-0 : %d, received by node-8: %d\n",sentBy_0, receivedBy_8);
}


#https://ns2blogger.blogspot.com/p/the-file-written-by-application-or-by.html