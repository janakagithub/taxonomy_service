/*
A KBase module: taxonomy_service
This module serve as the taxonomy service in KBase.
*/

module taxonomy_service {
    /*
        A binary boolean
    */
    typedef int bool;

    /*
        workspace ref to an object
    */
    typedef string ObjectReference;

    typedef structure {
        int private;
        int public;
        int local;
        string search;
        int limit;
        int start;
        string workspace;
    }DropDownItemInputParams;

    typedef structure {
        string label;
        string id;
        string category;
        string parent;
        string parent_ref;
    } DropDownItem;

    typedef structure{
        int num_of_hits;
        list<DropDownItem> hits;
    } DropDownData;

    funcdef search_taxonomy (DropDownItemInputParams params) returns (DropDownData output) authentication required;


    typedef structure{
        string scientific_name;
        int taxonomic_id;
        string kingdom;
        string domain;
        string rank;
        string comments;
        string genetic_code;
        list <string> aliases;
        string workspace;
    }CreateTaxonomyInputParams;

    typedef structure {
        ObjectReference ref;
        string scientific_name;
    }CreateTaxonomyOut;

    funcdef create_taxonomy (CreateTaxonomyInputParams params) returns (CreateTaxonomyOut output) authentication required;


    typedef structure{
        list<ObjectReference> taxonomy_object_refs;

    }GetTaxonomiesIdInputParams;


    typedef structure {
        ObjectReference ref;
        string scientific_name;
    } TaxonInfo;

    typedef structure{
        list<ObjectReference> children;
        list<TaxonInfo> decorated_children;
        list<string> scientific_lineage;
        list<TaxonInfo> decorated_scientific_lineage;
        string scientific_name;
        int taxonomic_id;
        string kingdom;
        string domain;
        int genetic_code;
        list <string> aliases;

    }Taxon;

    typedef structure{
        string input_genome;
        string scientific_name;
        string workspace;
        string output_genome;
    }ChangeTaxaInputParams;

    typedef structure{
        string genome_ref;
        string taxa_ref;
        string genome_name;
    }ChangeTaxaOut;

    funcdef change_taxa (ChangeTaxaInputParams params) returns (ChangeTaxaOut output) authentication required;

    typedef structure{
      string taxa_ref;
      string parent_ref;
    }TaxaViewerInput;

    typedef structure {
      int num_genomes;
      string lineage;
      string lineage_ref;
      int lineage_pos;
    } GenomeTaxaCount;

    typedef structure{
        string scientific_name;
        string kingdom;
        string ws_ref;
        string parent_taxon_ref;
        int deleted;
        list <string> aliases;
        string scientific_lineage;
    }TaxaViewerOutput;


    typedef structure{
       string lineage_step;
       int lineage_count;
    }lineage_steps;


    typedef structure{
        string taxa_ref;
        list <lineage_steps> lineage_genomes;
    }GetTaxonomiesOut;

    typedef structure{
        string taxa_ref;
    }GetGenomesTaxonomyInputParams;


    typedef structure{
        string lineage_step;
        int lineage_count;
        list <TaxaViewerOutput> TaxaInfo;
    }GetGenomesOut;

     typedef structure{
        int start;
        int limit;
        string lineage_step;
    }GetGenomesTaxaGroupInputParams;

    funcdef get_taxonomies_by_id(GetTaxonomiesIdInputParams params) returns (GetTaxonomiesOut output) authentication required;

    funcdef get_genomes_for_taxonomy (GetGenomesTaxonomyInputParams params) returns (GetTaxonomiesOut output) authentication required;

    funcdef get_genomes_for_taxa_group (GetGenomesTaxaGroupInputParams params) returns (GetGenomesOut output) authentication required;

};
