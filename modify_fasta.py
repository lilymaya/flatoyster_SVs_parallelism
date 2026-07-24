# created by Camille Roux

import argparse

def count_stop_codons(sequence):
	# Definir les codons stop
	stop_codons = ['TAA', 'TAG', 'TGA']
	
	# Compter le nombre de codons stop dans la sequence
	liste_codons = [sequence[i:i+3] for i in range(0, len(sequence)-len(sequence)%3, 3)]
	nStop_codons = sum( 1 for codon in liste_codons if codon in stop_codons )
	return nStop_codons


def modify_fasta_identifiers_and_calculate_stats(fasta_file_path, correspondance_file_path, output_file_path):
	# Lire la table de correspondance pour creer un dictionnaire
	correspondance_dict = {}
	with open(correspondance_file_path, 'r') as file:
		for line in file:
			parts = line.strip().split()  # Assumer que les colonnes sont separees par des espaces ou des tabulations
			if len(parts) == 2:
				correspondance_dict[parts[0]] = parts[1]

	# Lire le fichier fasta
	fasta_dict = {}
	max_stop_codons = 0
	locus_length = 0
	with open(fasta_file_path, 'r') as file:
		identifier = ""
		sequence = ""
		for line in file:
			line = line.strip()
			if line.startswith(">"):  # Nouvel identifiant
				if identifier:  # Sauvegarder la sequence precedente et calculer les codons stop
					stop_codons_count = count_stop_codons(sequence)
					max_stop_codons = max(max_stop_codons, stop_codons_count)
					fasta_dict[identifier] = sequence
				identifier = line[1:]  # Enlever le '>'
				sequence = ""  # Reinitialiser la sequence
			else:
				sequence += line
		
		# Sauvegarder la derniere sequence et calculer pour elle aussi
		if identifier:
			stop_codons_count = count_stop_codons(sequence)
			max_stop_codons = max(max_stop_codons, stop_codons_count)
			fasta_dict[identifier] = sequence

	# Determiner la longueur du locus comme etant la longueur de la premiere sequence
	if fasta_dict:
		locus_length = len(next(iter(fasta_dict.values())))

	# Nom du gene deduit du nom du fichier fasta
	gene_name = fasta_file_path.split('/')[-1].split('.')[0]

	# Modifier les identifiants des sequences et ecrire le nouveau fichier fasta
	with open(output_file_path, 'w') as new_file:
		for identifier, sequence in fasta_dict.items():
			# Extraire le nom de l'individu et l'allele de l'identifiant
			individual_name, allele = identifier.rsplit('_', 1)
	
			# Modifier l'allele pour retirer le "0" initial si necessaire
			allele = str(int(allele))  # Convertit "01" ou "02" en "1" ou "2"

			# Trouver le nom de la population à partir du dictionnaire de correspondance
			population_name = correspondance_dict.get(individual_name, "Unknown")

			# Construire le nouvel identifiant
			new_identifier = f">{gene_name}|{population_name}|{individual_name}|Allele_{allele}"

			# Écrire le nouvel identifiant et la sequence dans le fichier
			new_file.write(f"{new_identifier}\n{sequence}\n")

	# Retourner la longueur du locus et le nombre max de codons stop
	return gene_name, locus_length, max_stop_codons


if __name__ == "__main__":
	parser = argparse.ArgumentParser(description="Modify fasta file identifiers and calculate stop codons stats.")
	parser.add_argument("fasta_file_path", help="Path to the fasta file.")
	parser.add_argument("correspondance_file_path", help="Path to the correspondence table file.")
	parser.add_argument("output_file_path", help="Path where the modified fasta file will be saved.")

	args = parser.parse_args()

	gene_name, locus_length, max_stop_codons = modify_fasta_identifiers_and_calculate_stats(args.fasta_file_path, args.correspondance_file_path, args.output_file_path)
	#print(f"Gene name: {gene_name}")
	#print(f"Locus Length: {locus_length}")
	#print(f"Maximum Number of Stop Codons: {max_stop_codons}")
	print(f"{gene_name}\t{locus_length}\t{max_stop_codons}")
