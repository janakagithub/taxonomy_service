
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
 * <p>Original spec-file type: GetTaxonomiesOut</p>
 * 
 * 
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
@Generated("com.googlecode.jsonschema2pojo")
@JsonPropertyOrder({
    "taxon_objects"
})
public class GetTaxonomiesOut {

    @JsonProperty("taxon_objects")
    private List<Taxon> taxonObjects;
    private Map<String, Object> additionalProperties = new HashMap<String, Object>();

    @JsonProperty("taxon_objects")
    public List<Taxon> getTaxonObjects() {
        return taxonObjects;
    }

    @JsonProperty("taxon_objects")
    public void setTaxonObjects(List<Taxon> taxonObjects) {
        this.taxonObjects = taxonObjects;
    }

    public GetTaxonomiesOut withTaxonObjects(List<Taxon> taxonObjects) {
        this.taxonObjects = taxonObjects;
        return this;
    }

    @JsonAnyGetter
    public Map<String, Object> getAdditionalProperties() {
        return this.additionalProperties;
    }

    @JsonAnySetter
    public void setAdditionalProperties(String name, Object value) {
        this.additionalProperties.put(name, value);
    }

    @Override
    public String toString() {
        return ((((("GetTaxonomiesOut"+" [taxonObjects=")+ taxonObjects)+", additionalProperties=")+ additionalProperties)+"]");
    }

}
