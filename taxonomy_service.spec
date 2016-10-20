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
        bool private;
        bool public;
        string search;
        int limit;
        int start;
    }DropDownItemInputParams;

    typedef structure {
        string label;
        string id;
        string category;
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
        int genetic_code;
        list <string> aliases;
        list <string> scientific_lineage;
        string workspace_name;
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

    typedef structure {
        list <Taxon> taxon_objects;
    }GetTaxonomiesOut;



 funcdef get_taxonomies_by_id(GetTaxonomiesIdInputParams params) returns (GetTaxonomiesOut output) authentication required;

    typedef structure{
        string search;
        int limit;
        int start;
    }GetTaxonomiesQueryInputParams;


    funcdef get_taxonomies_by_query (GetTaxonomiesQueryInputParams params) returns (GetTaxonomiesOut output) authentication required;

    typedef structure{
        string search;
        int limit;
        int start;
    }GetGenomesTaxonomyInputParams;

    funcdef get_genomes_for_taxonomy (GetGenomesTaxonomyInputParams params) returns (GetTaxonomiesOut output) authentication required;
};
