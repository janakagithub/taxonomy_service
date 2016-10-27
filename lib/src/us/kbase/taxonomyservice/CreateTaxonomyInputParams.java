
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
 * <p>Original spec-file type: CreateTaxonomyInputParams</p>
 * 
 * 
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
@Generated("com.googlecode.jsonschema2pojo")
@JsonPropertyOrder({
    "scientific_name",
    "taxonomic_id",
    "kingdom",
    "domain",
    "rank",
    "embl_code",
    "comments",
    "genetic_code",
    "aliases",
    "scientific_lineage",
    "workspace"
})
public class CreateTaxonomyInputParams {

    @JsonProperty("scientific_name")
    private java.lang.String scientificName;
    @JsonProperty("taxonomic_id")
    private Long taxonomicId;
    @JsonProperty("kingdom")
    private java.lang.String kingdom;
    @JsonProperty("domain")
    private java.lang.String domain;
    @JsonProperty("rank")
    private java.lang.String rank;
    @JsonProperty("embl_code")
    private java.lang.String emblCode;
    @JsonProperty("comments")
    private java.lang.String comments;
    @JsonProperty("genetic_code")
    private Long geneticCode;
    @JsonProperty("aliases")
    private List<String> aliases;
    @JsonProperty("scientific_lineage")
    private List<String> scientificLineage;
    @JsonProperty("workspace")
    private java.lang.String workspace;
    private Map<java.lang.String, Object> additionalProperties = new HashMap<java.lang.String, Object>();

    @JsonProperty("scientific_name")
    public java.lang.String getScientificName() {
        return scientificName;
    }

    @JsonProperty("scientific_name")
    public void setScientificName(java.lang.String scientificName) {
        this.scientificName = scientificName;
    }

    public CreateTaxonomyInputParams withScientificName(java.lang.String scientificName) {
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

    public CreateTaxonomyInputParams withTaxonomicId(Long taxonomicId) {
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

    public CreateTaxonomyInputParams withKingdom(java.lang.String kingdom) {
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

    public CreateTaxonomyInputParams withDomain(java.lang.String domain) {
        this.domain = domain;
        return this;
    }

    @JsonProperty("rank")
    public java.lang.String getRank() {
        return rank;
    }

    @JsonProperty("rank")
    public void setRank(java.lang.String rank) {
        this.rank = rank;
    }

    public CreateTaxonomyInputParams withRank(java.lang.String rank) {
        this.rank = rank;
        return this;
    }

    @JsonProperty("embl_code")
    public java.lang.String getEmblCode() {
        return emblCode;
    }

    @JsonProperty("embl_code")
    public void setEmblCode(java.lang.String emblCode) {
        this.emblCode = emblCode;
    }

    public CreateTaxonomyInputParams withEmblCode(java.lang.String emblCode) {
        this.emblCode = emblCode;
        return this;
    }

    @JsonProperty("comments")
    public java.lang.String getComments() {
        return comments;
    }

    @JsonProperty("comments")
    public void setComments(java.lang.String comments) {
        this.comments = comments;
    }

    public CreateTaxonomyInputParams withComments(java.lang.String comments) {
        this.comments = comments;
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

    public CreateTaxonomyInputParams withGeneticCode(Long geneticCode) {
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

    public CreateTaxonomyInputParams withAliases(List<String> aliases) {
        this.aliases = aliases;
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

    public CreateTaxonomyInputParams withScientificLineage(List<String> scientificLineage) {
        this.scientificLineage = scientificLineage;
        return this;
    }

    @JsonProperty("workspace")
    public java.lang.String getWorkspace() {
        return workspace;
    }

    @JsonProperty("workspace")
    public void setWorkspace(java.lang.String workspace) {
        this.workspace = workspace;
    }

    public CreateTaxonomyInputParams withWorkspace(java.lang.String workspace) {
        this.workspace = workspace;
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
        return ((((((((((((((((((((((((("CreateTaxonomyInputParams"+" [scientificName=")+ scientificName)+", taxonomicId=")+ taxonomicId)+", kingdom=")+ kingdom)+", domain=")+ domain)+", rank=")+ rank)+", emblCode=")+ emblCode)+", comments=")+ comments)+", geneticCode=")+ geneticCode)+", aliases=")+ aliases)+", scientificLineage=")+ scientificLineage)+", workspace=")+ workspace)+", additionalProperties=")+ additionalProperties)+"]");
    }

}
