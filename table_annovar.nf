params.help = null
params.out_folder = "."
params.table_extension = "tsv"
params.thread = 1

if (params.help) {
    log.info ''
    log.info '--------------------------------------------------'
    log.info '                   TABLE ANNOVAR                  '
    log.info '--------------------------------------------------'
    log.info ''
    log.info 'Usage: '
    log.info 'nextflow run table_annovar.nf --table_folder myinputfolder'
    log.info ''
    log.info 'Mandatory arguments:'
    log.info '    --table_folder       FOLDER            Folder containing tables to process.'
    log.info 'Optional arguments:'
    log.info ''
    log.info ''
    exit 1
}

tables = Channel.fromPath( params.table_folder+'*.'+params.table_extension)
                 .ifEmpty { error "empty table folder, please verify your input." }

process annovar {

  publishDir params.out_folder, mode: 'move'

  tag { file_name }

  cpus params.thread

  input:
  file tables

  output:
  file "*multianno.txt" into output_annovar

  shell:
  file_name = tables.baseName
  '''
  table_annovar.pl -nastring NA -buildver hg19 --thread !{params.thread} --onetranscript -remove -protocol refGene,knownGene,ensGene,cytoBand,genomicSuperDups,tfbsConsSites,gwasCatalog,avsnp147,popfreq_all_20150413,exac03nontcga,kaviar_20150923,cosmic80,clinvar_20170130,revel,dbnsfp33a,dbnsfp31a_interpro,dbscsnv11 -operation g,g,g,r,r,r,r,f,f,f,f,f,f,f,f,f,f -otherinfo !{tables} /appli57/annovar/Annovar_DB/hg19db
  sed -i '1s/Otherinfo/QUAL\tFILTER\tINFO\tFORMAT\tNORMAL\tPRIMARY\tID\tIndividual\tStudy/' !{tables}.hg19_multianno.txt
  '''

}
