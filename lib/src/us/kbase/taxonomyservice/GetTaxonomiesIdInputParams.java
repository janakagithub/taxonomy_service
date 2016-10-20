
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
 * <p>Original spec-file type: GetTaxonomiesIdInputParams</p>
 * 
 * 
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
@Generated("com.googlecode.jsonschema2pojo")
@JsonPropertyOrder({
    "taxonomy_object_refs"
})
public class GetTaxonomiesIdInputParams {

    @JsonProperty("taxonomy_object_refs")
    private List<String> taxonomyObjectRefs;
    private Map<java.lang.String, Object> additionalProperties = new HashMap<java.lang.String, Object>();

    @JsonProperty("taxonomy_object_refs")
    public List<String> getTaxonomyObjectRefs() {
        return taxonomyObjectRefs;
    }

    @JsonProperty("taxonomy_object_refs")
    public void setTaxonomyObjectRefs(List<String> taxonomyObjectRefs) {
        this.taxonomyObjectRefs = taxonomyObjectRefs;
    }

    public GetTaxonomiesIdInputParams withTaxonomyObjectRefs(List<String> taxonomyObjectRefs) {
        this.taxonomyObjectRefs = taxonomyObjectRefs;
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
        return ((((("GetTaxonomiesIdInputParams"+" [taxonomyObjectRefs=")+ taxonomyObjectRefs)+", additionalProperties=")+ additionalProperties)+"]");
    }

}
