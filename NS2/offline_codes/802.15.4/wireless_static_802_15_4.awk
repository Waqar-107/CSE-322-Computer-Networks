BEGIN {
    max_node = 2000;
	nSentPackets = 0.0 ;		
	nReceivedPackets = 0.0 ;
	rTotalDelay = 0.0 ;
	max_pckt = 10000;
	
	idHighestPacket = 0;
	idLowestPacket = 100000;
	rStartTime = 10000.0;		#start of receive
	rEndTime = 0.0;				#end of receive
	nReceivedBytes = 0;

	dropPackets = 0.0;

	total_energy_consumption = 0;

	temp = 0;
	
	for (i=0; i<max_node; i++) {
		energy_consumption[i] = 0;		
	}

	total_retransmit = 0;
	for (i=0; i<max_pckt; i++) {
		retransmit[i] = 0;	
		rDelay[i] = 0;		
	}

	for (i=0; i<max_node; i++) {
		byteReceivedByNode[i] = 0;
	}
}

{
	#	event = $1;    time = $2;    node = $3;    type = $4;    reason = $5;    node2 = $5;    
	#	packetid = $6;    mac_sub_type=$7;    size=$8;    source = $11;    dest = $10;    energy=$14;

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

	if(receiveAgt == "AGT" && messageType == "cbr") {
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

	if(messageType == "cbr") {
		#printf("%d %15d\n", packetID, num_retransmit);
		retransmit[packetID] = num_retransmit;
	}

	if(event == "D" && messageType == "cbr") {
		dropPackets++;
		if(receiveTime > rEndTime) rEndTime = receiveTime;
		if(receiveTime < rStartTime) rStartTime = receiveTime;
	}

}

END {
	#---------------------------------------------------------------------
	printf("total packets sent: %d\n",nSentPackets);
	printf("total packets received: %d\n", nReceivedPackets);
	printf("packets dropped: %d\n",dropPackets);
	#---------------------------------------------------------------------

	#---------------------------------------------------------------------
	rTime = rEndTime - rStartTime;
	printf("start: %f | stop: %f\n", rStartTime, rEndTime);
	rThroughput = nReceivedBytes*8 / rTime;
	rPacketDeliveryRatio = nReceivedPackets / nSentPackets * 100;
	rPacketDropRatio = dropPackets / nSentPackets * 100

	avg_time = 0;
	for(i=0; i<max_pckt;i++)avg_time+=rDelay[i];
	avg_time/=nReceivedPackets;
	printf("avg time for pkt to travel aka end-to-end delay: %f\n",avg_time);

	printf("throughput: %f bps\n", rThroughput);
	printf("packet delivery ratio: %f\n", rPacketDeliveryRatio);
	printf("packet drop ratio: %f\n",rPacketDropRatio);
	#---------------------------------------------------------------------

	#---------------------------------------------------------------------
	for(i=0; i<max_node;i++) {
		total_energy_consumption += energy_consumption[i];
	}

	printf("total energy consumed: %f\n", total_energy_consumption);
	#---------------------------------------------------------------------

	#---------------------------------------------------------------------
	if (nReceivedPackets != 0) {
		rAverageDelay = rTotalDelay / nReceivedPackets ;
		#avg_energy_per_packet = total_energy_consumption / nReceivedPackets ;
		printf("avg delay: %f\n", rAverageDelay);
	}
	#---------------------------------------------------------------------

	#BONUS
	#---------------------------------------------------------------------
	#per node throughput-> node that has the most throughput
	printf("\nother metrics:\n");
	mx = 0.0; n = -1
	for(i=0; i<max_node; i++) {
		temp = byteReceivedByNode[i] * 8 / rTime;
		if(mx < temp) {
			mx = temp;
			n = i;
		}
	}
	printf("node %d has the most throughput : %f bps\n", n, mx);
	#---------------------------------------------------------------------

	#---------------------------------------------------------------------
	if ( nReceivedPackets != 0 ) {
		rAverageDelay = rTotalDelay / nReceivedPackets ;
		avg_energy_per_packet = total_energy_consumption / nReceivedPackets ;
	}

	if ( nReceivedBytes != 0 ) {
		avg_energy_per_byte = total_energy_consumption / nReceivedBytes ;
		avg_energy_per_bit = avg_energy_per_byte / 8;
	}

	for (i=0; i<max_pckt; i++) {
		total_retransmit += retransmit[i] ;		
		#printf("%d %15.5f\n", i, retransmit[i]);
	}

	printf("average delay: %f\n", rAverageDelay);
	printf("average energy per packet: %f joules\n", avg_energy_per_packet);
	printf("average energy per bit: %f joules\n", avg_energy_per_bit);
	printf("average energy per byte: %f joules\n", avg_energy_per_byte);
	printf("total retransmit: %d\n", total_retransmit);
	#---------------------------------------------------------------------

	printf("\n");
}