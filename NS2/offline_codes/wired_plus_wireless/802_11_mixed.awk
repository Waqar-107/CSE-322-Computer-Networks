BEGIN {
   for(i=0;i<7;i++)
   {
	for(j=0;j<7;j++){
		rec[i, j] = 0;
		snd[i, j] = 0;
	}
   }
}

{
	dec = $4
	event = $1

	if(dec == "-Hs") {
		from_node = $5;
    		to_node = $7;
		type = $35;
	}

	else{
		from_node = $3;
    		to_node = $4;
		type = $5
	}
	

	sub(/^-/,"",from_node);
	sub(/^-/,"",to_node);

	
	if(type == "tcp") {
	
		if(event == "s") {	
            	#printf("from: %d to: %d\n", from_node, to_node);
			snd[from_node, to_node]++;
		}

		if(event == "r") {
			#printf("from: %d to: %d\n", from_node, to_node);
			rec[to_node, from_node]++;
		}
	}
	

	if(event == "D" && type == "tcp") {
		dropPackets++;
	}

}

END {
	for(i=0;i<7;i++)
	{
		printf("from node: %d\n",i);
		for(j=0;j<7;j++) printf("sent to %d: %d, received by %d: %d\n", j, snd[i, j], j, rec[j, i]);
	}
}