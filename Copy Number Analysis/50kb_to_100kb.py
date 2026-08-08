#WIG File Converter: 50kb to 100kb Resolution
#Takes two consecutive values from a 50kb WIG file and averages them to create a 100kb version. If either value is -1, the output is -1 (preserving missing data).
#Last Edit: 31/07/26 - TM

#Set file input and output paths (Run once with map and once with gc)
input_file = 'map_hg38_50kb.wig'
output_file = 'map_hg38_100kb.wig' 

#Read all lines from input file
with open(input_file) as f:
	lines = f.readlines()

#Create list to hold output lines
out_lines = []
#Track input position
i = 0

#Loop through input, pair values, write output
while i < len(lines):
	#Remove newline and whitespace
	line = lines[i].strip()
    
	#Pass through header lines unchanged
	if line.startswith('fixedStep'):
		#If using different window sizes, change values as needed
		out_lines.append(line.replace('50000', '100000') + '\n')
		i += 1
		continue
    
	#Skip empty lines
	elif line == '':
		i += 1
		continue
    
	#Process pairs of numbers (2 x 50kb = 100kb), but only if next line isn't a header
	elif i + 1 < len(lines) and not lines[i+1].strip().startswith('fixedStep'):
		n1 = float(lines[i].strip())
		n2 = float(lines[i+1].strip())
        
        #If either is -1, output -1
		if n1 == -1 or n2 == -1:
			out_lines.append('-1\n')
			
		else:
			#Average the two values
				out_lines.append(str((n1 + n2) / 2) + '\n')
		#Move forward by 2
		i += 2
	
	#Handle left over value
	else:
		out_lines.append(line + '\n')
		i += 1

#Write output to file
with open(output_file, 'w') as f:
	f.writelines(out_lines)

print('Finished')
