BEGIN {
	count = 0;
}

{
	printf("Event name: ");
	print($1);

	printf("time: ");
	print($2);

	node = $3;
	sub(/_/,"",node);
	sub(/_/,"",node);
	printf("node: ");
	print(node);

	pckID = $6;
	printf("packet id: ");
	print(pckID)

	totalEnergy = $14;
	printf("total energy: %s\n",totalEnergy);
}

END {
}
