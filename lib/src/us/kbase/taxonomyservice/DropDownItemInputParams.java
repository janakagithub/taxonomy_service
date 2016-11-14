
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
 * <p>Original spec-file type: DropDownItemInputParams</p>
 * 
 * 
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
@Generated("com.googlecode.jsonschema2pojo")
@JsonPropertyOrder({
    "private",
    "public",
    "local",
    "search",
    "limit",
    "start",
    "workspace"
})
public class DropDownItemInputParams {

    @JsonProperty("private")
    private Long _private;
    @JsonProperty("public")
    private Long _public;
    @JsonProperty("local")
    private Long local;
    @JsonProperty("search")
    private String search;
    @JsonProperty("limit")
    private Long limit;
    @JsonProperty("start")
    private Long start;
    @JsonProperty("workspace")
    private String workspace;
    private Map<String, Object> additionalProperties = new HashMap<String, Object>();

    @JsonProperty("private")
    public Long getPrivate() {
        return _private;
    }

    @JsonProperty("private")
    public void setPrivate(Long _private) {
        this._private = _private;
    }

    public DropDownItemInputParams withPrivate(Long _private) {
        this._private = _private;
        return this;
    }

    @JsonProperty("public")
    public Long getPublic() {
        return _public;
    }

    @JsonProperty("public")
    public void setPublic(Long _public) {
        this._public = _public;
    }

    public DropDownItemInputParams withPublic(Long _public) {
        this._public = _public;
        return this;
    }

    @JsonProperty("local")
    public Long getLocal() {
        return local;
    }

    @JsonProperty("local")
    public void setLocal(Long local) {
        this.local = local;
    }

    public DropDownItemInputParams withLocal(Long local) {
        this.local = local;
        return this;
    }

    @JsonProperty("search")
    public String getSearch() {
        return search;
    }

    @JsonProperty("search")
    public void setSearch(String search) {
        this.search = search;
    }

    public DropDownItemInputParams withSearch(String search) {
        this.search = search;
        return this;
    }

    @JsonProperty("limit")
    public Long getLimit() {
        return limit;
    }

    @JsonProperty("limit")
    public void setLimit(Long limit) {
        this.limit = limit;
    }

    public DropDownItemInputParams withLimit(Long limit) {
        this.limit = limit;
        return this;
    }

    @JsonProperty("start")
    public Long getStart() {
        return start;
    }

    @JsonProperty("start")
    public void setStart(Long start) {
        this.start = start;
    }

    public DropDownItemInputParams withStart(Long start) {
        this.start = start;
        return this;
    }

    @JsonProperty("workspace")
    public String getWorkspace() {
        return workspace;
    }

    @JsonProperty("workspace")
    public void setWorkspace(String workspace) {
        this.workspace = workspace;
    }

    public DropDownItemInputParams withWorkspace(String workspace) {
        this.workspace = workspace;
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
        return ((((((((((((((((("DropDownItemInputParams"+" [_private=")+ _private)+", _public=")+ _public)+", local=")+ local)+", search=")+ search)+", limit=")+ limit)+", start=")+ start)+", workspace=")+ workspace)+", additionalProperties=")+ additionalProperties)+"]");
    }

}
