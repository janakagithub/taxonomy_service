
package us.kbase.taxonomyservice;

import java.util.HashMap;
import java.util.Map;
import javax.annotation.Generated;
import com.fasterxml.jackson.annotation.JsonAnyGetter;
import com.fasterxml.jackson.annotation.JsonAnySetter;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyOrder;


/**
 * <p>Original spec-file type: DropDownItem</p>
 * 
 * 
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
@Generated("com.googlecode.jsonschema2pojo")
@JsonPropertyOrder({
    "label",
    "id",
    "category",
    "parent",
    "parent_ref"
})
public class DropDownItem {

    @JsonProperty("label")
    private String label;
    @JsonProperty("id")
    private String id;
    @JsonProperty("category")
    private String category;
    @JsonProperty("parent")
    private String parent;
    @JsonProperty("parent_ref")
    private String parentRef;
    private Map<String, Object> additionalProperties = new HashMap<String, Object>();

    @JsonProperty("label")
    public String getLabel() {
        return label;
    }

    @JsonProperty("label")
    public void setLabel(String label) {
        this.label = label;
    }

    public DropDownItem withLabel(String label) {
        this.label = label;
        return this;
    }

    @JsonProperty("id")
    public String getId() {
        return id;
    }

    @JsonProperty("id")
    public void setId(String id) {
        this.id = id;
    }

    public DropDownItem withId(String id) {
        this.id = id;
        return this;
    }

    @JsonProperty("category")
    public String getCategory() {
        return category;
    }

    @JsonProperty("category")
    public void setCategory(String category) {
        this.category = category;
    }

    public DropDownItem withCategory(String category) {
        this.category = category;
        return this;
    }

    @JsonProperty("parent")
    public String getParent() {
        return parent;
    }

    @JsonProperty("parent")
    public void setParent(String parent) {
        this.parent = parent;
    }

    public DropDownItem withParent(String parent) {
        this.parent = parent;
        return this;
    }

    @JsonProperty("parent_ref")
    public String getParentRef() {
        return parentRef;
    }

    @JsonProperty("parent_ref")
    public void setParentRef(String parentRef) {
        this.parentRef = parentRef;
    }

    public DropDownItem withParentRef(String parentRef) {
        this.parentRef = parentRef;
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
        return ((((((((((((("DropDownItem"+" [label=")+ label)+", id=")+ id)+", category=")+ category)+", parent=")+ parent)+", parentRef=")+ parentRef)+", additionalProperties=")+ additionalProperties)+"]");
    }

}
