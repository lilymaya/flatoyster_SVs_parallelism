# created by Benjamin Penaud

#!/bin/bash

awk -F "\t" 'BEGIN{c_chr="";chr="";header_b="";header_a="";header=0}{
    if($0 ~ /^#/){
        if($0 ~ /^##contig=<ID=/){
            print
            match($0, /^##contig=<ID=(.+),length=([0-9]+)>/, q)
            dchr2len[q[1]]=q[2]
            header++
        }
        if($0 !~ /^##contig=<ID=/ && header<1){
            print
            if(header_b != ""){
                header_b=header_b"\n"$0
            }else{
                header_b=$0
            }
        }else if($0 !~ /^##contig=<ID=/ && header>=1){
            print
            if(header_a != ""){
                header_a=header_a"\n"$0
            }else{
                header_a=$0
            }
        }
        if($0 ~ /^#CHROM/){
            baseline=".\tN\t.\t.\t.\t.\tGT:DP:RGQ"
            for(i=10;i<=NF;i++){
                baseline=baseline"\t0/0:.:."
            }
        }
    }else{
        c_chr=$1
        if(c_chr != chr){
            if(chr in dchr2len){
                for(i=pos+1;i<=dchr2len[chr];i++){
                    print chr"\t"i"\t"baseline >chr".vcf"
                    print chr"\t"i"\t"baseline
                }
                pos=1
                delete dchr2len[chr]
                chr=c_chr
                print header_b"\n##contig=<ID="c_chr",length="dchr2len[c_chr]">\n"header_a >c_chr".vcf"
                for(i=pos;i<$2;i++){
                    print c_chr"\t"i"\t"baseline >c_chr".vcf"
                    print c_chr"\t"i"\t"baseline
                }
                print $0 >c_chr".vcf"
                print $0
                pos=$2
            }else{
                chr=c_chr
                pos=1
                print header_b"\n##contig=<ID="c_chr",length="dchr2len[c_chr]">\n"header_a >c_chr".vcf"
                for(i=pos;i<$2;i++){
                    print c_chr"\t"i"\t"baseline >c_chr".vcf"
                    print c_chr"\t"i"\t"baseline
                }
                print $0 >c_chr".vcf"
                print $0
                pos=$2
            }
        }else{
            if($2==pos+1){
                print $0 >c_chr".vcf"
                print $0
                pos=$2
            }else if($2>pos+1){
                for(i=pos+1;i<$2;i++){
                    print c_chr"\t"i"\t"baseline >c_chr".vcf"
                    print c_chr"\t"i"\t"baseline
                }
                print $0 >c_chr".vcf"
                print $0
                pos=$2
            }
        }
    }
}END{
    for(i=pos+1;i<=dchr2len[c_chr];i++){
        print c_chr"\t"i"\t"baseline >c_chr".vcf"
        print c_chr"\t"i"\t"baseline
    }
    delete dchr2len[c_chr]
    for(c in dchr2len){
        for(i=1;i<=dchr2len[c];i++){
            print c"\t"i"\t"baseline
        }
    }
}' final_dils_input.vcf > complete_final_dils_input.vcf
