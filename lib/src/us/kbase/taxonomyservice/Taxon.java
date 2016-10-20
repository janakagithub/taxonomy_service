
package us.kbase.taxonomyservice;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.annotation.Generated;
import com.fasterxml.jackson.annotation.JsonAnyGetter;
import com.fasterxml.jackson.annotation.JsonAnySetter;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyOrder;


/**
 * <p>Original spec-file type: Taxon</p>
 * 
 * 
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
@Generated("com.googlecode.jsonschema2pojo")
@JsonPropertyOrder({
    "children",
    "decorated_children",
    "scientific_lineage",
    "decorated_scientific_lineage",
    "scientific_name",
    "taxonomic_id",
    "kingdom",
    "domain",
    "genetic_code",
    "aliases"
})
public class Taxon {

    @JsonProperty("children")
    private List<String> children;
    @JsonProperty("decorated_children")
    private List<us.kbase.taxonomyservice.TaxonInfo> decoratedChildren;
    @JsonProperty("scientific_lineage")
    private List<String> scientificLineage;
    @JsonProperty("decorated_scientific_lineage")
    private List<us.kbase.taxonomyservice.TaxonInfo> decoratedScientificLineage;
    @JsonProperty("scientific_name")
    private java.lang.String scientificName;
    @JsonProperty("taxonomic_id")
    private Long taxonomicId;
    @JsonProperty("kingdom")
    private java.lang.String kingdom;
    @JsonProperty("domain")
    private java.lang.String domain;
    @JsonProperty("genetic_code")
    private Long geneticCode;
    @JsonProperty("aliases")
    private List<String> aliases;
    private Map<java.lang.String, Object> additionalProperties = new HashMap<java.lang.String, Object>();

    @JsonProperty("children")
    public List<String> getChildren() {
        return children;
    }

    @JsonProperty("children")
    public void setChildren(List<String> children) {
        this.children = children;
    }

    public Taxon withChildren(List<String> children) {
        this.children = children;
        return this;
    }

    @JsonProperty("decorated_children")
    public List<us.kbase.taxonomyservice.TaxonInfo> getDecoratedChildren() {
        return decoratedChildren;
    }

    @JsonProperty("decorated_children")
    public void setDecoratedChildren(List<us.kbase.taxonomyservice.TaxonInfo> decoratedChildren) {
        this.decoratedChildren = decoratedChildren;
    }

    public Taxon withDecoratedChildren(List<us.kbase.taxonomyservice.TaxonInfo> decoratedChildren) {
        this.decoratedChildren = decoratedChildren;
        return this;
    }

    @JsonProperty("scientific_lineage")
    public List<String> getScientificLineage() {
        return scientificLineage;
    }

    @JsonProperty("scientific_lineage")
    public void setScientificLineage(List<String> scientificLineage) {
        this.scientificLineage = scientificLineage;
    }

    public Taxon withScientificLineage(List<String> scientificLineage) {
        this.scientificLineage = scientificLineage;
        return this;
    }

    @JsonProperty("decorated_scientific_lineage")
    public List<us.kbase.taxonomyservice.TaxonInfo> getDecoratedScientificLineage() {
        return decoratedScientificLineage;
    }

    @JsonProperty("decorated_scientific_lineage")
    public void setDecoratedScientificLineage(List<us.kbase.taxonomyservice.TaxonInfo> decoratedScientificLineage) {
        this.decoratedScientificLineage = decoratedScientificLineage;
    }

    public Taxon withDecoratedScientificLineage(List<us.kbase.taxonomyservice.TaxonInfo> decoratedScientificLineage) {
        this.decoratedScientificLineage = decoratedScientificLineage;
        return this;
    }

    @JsonProperty("scientific_name")
    public java.lang.String getScientificName() {
        return scientificName;
    }

    @JsonProperty("scientific_name")
    public void setScientificName(java.lang.String scientificName) {
        this.scientificName = scientificName;
    }

    public Taxon withScientificName(java.lang.String scientificName) {
        this.scientificName = scientificName;
        return this;
    }

    @JsonProperty("taxonomic_id")
    public Long getTaxonomicId() {
        return taxonomicId;
    }

    @JsonProperty("taxonomic_id")
    public void setTaxonomicId(Long taxonomicId) {
        this.taxonomicId = taxonomicId;
    }

    public Taxon withTaxonomicId(Long taxonomicId) {
        this.taxonomicId = taxonomicId;
        return this;
    }

    @JsonProperty("kingdom")
    public java.lang.String getKingdom() {
        return kingdom;
    }

    @JsonProperty("kingdom")
    public void setKingdom(java.lang.String kingdom) {
        this.kingdom = kingdom;
    }

    public Taxon withKingdom(java.lang.String kingdom) {
        this.kingdom = kingdom;
        return this;
    }

    @JsonProperty("domain")
    public java.lang.String getDomain() {
        return domain;
    }

    @JsonProperty("domain")
    public void setDomain(java.lang.String domain) {
        this.domain = domain;
    }

    public Taxon withDomain(java.lang.String domain) {
        this.domain = domain;
        return this;
    }

    @JsonProperty("genetic_code")
    public Long getGeneticCode() {
        return geneticCode;
    }

    @JsonProperty("genetic_code")
    public void setGeneticCode(Long geneticCode) {
        this.geneticCode = geneticCode;
    }

    public Taxon withGeneticCode(Long geneticCode) {
        this.geneticCode = geneticCode;
        return this;
    }

    @JsonProperty("aliases")
    public List<String> getAliases() {
        return aliases;
    }

    @JsonProperty("aliases")
    public void setAliases(List<String> aliases) {
        this.aliases = aliases;
    }

    public Taxon withAliases(List<String> aliases) {
        this.aliases = aliases;
        return this;
    }

    @JsonAnyGetter
    public Map<java.lang.String, Object> getAdditionalProperties() {
        return this.additionalProperties;
    }

    @JsonAnySetter
    public void setAdditionalProperties(java.lang.String name, Object value) {
        this.additionalProperties.put(name, value);
    }

    @Override
    public java.lang.String toString() {
        return ((((((((((((((((((((((("Taxon"+" [children=")+ children)+", decoratedChildren=")+ decoratedChildren)+", scientificLineage=")+ scientificLineage)+", decoratedScientificLineage=")+ decoratedScientificLineage)+", scientificName=")+ scientificName)+", taxonomicId=")+ taxonomicId)+", kingdom=")+ kingdom)+", domain=")+ domain)+", geneticCode=")+ geneticCode)+", aliases=")+ aliases)+", additionalProperties=")+ additionalProperties)+"]");
    }

}
