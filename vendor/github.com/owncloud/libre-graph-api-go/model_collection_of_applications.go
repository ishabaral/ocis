/*
Libre Graph API

Libre Graph is a free API for cloud collaboration inspired by the MS Graph API.

API version: v1.0.1
*/

// Code generated by OpenAPI Generator (https://openapi-generator.tech); DO NOT EDIT.

package libregraph

import (
	"encoding/json"
)

// CollectionOfApplications struct for CollectionOfApplications
type CollectionOfApplications struct {
	Value []Application `json:"value,omitempty"`
}

// NewCollectionOfApplications instantiates a new CollectionOfApplications object
// This constructor will assign default values to properties that have it defined,
// and makes sure properties required by API are set, but the set of arguments
// will change when the set of required properties is changed
func NewCollectionOfApplications() *CollectionOfApplications {
	this := CollectionOfApplications{}
	return &this
}

// NewCollectionOfApplicationsWithDefaults instantiates a new CollectionOfApplications object
// This constructor will only assign default values to properties that have it defined,
// but it doesn't guarantee that properties required by API are set
func NewCollectionOfApplicationsWithDefaults() *CollectionOfApplications {
	this := CollectionOfApplications{}
	return &this
}

// GetValue returns the Value field value if set, zero value otherwise.
func (o *CollectionOfApplications) GetValue() []Application {
	if o == nil || o.Value == nil {
		var ret []Application
		return ret
	}
	return o.Value
}

// GetValueOk returns a tuple with the Value field value if set, nil otherwise
// and a boolean to check if the value has been set.
func (o *CollectionOfApplications) GetValueOk() ([]Application, bool) {
	if o == nil || o.Value == nil {
		return nil, false
	}
	return o.Value, true
}

// HasValue returns a boolean if a field has been set.
func (o *CollectionOfApplications) HasValue() bool {
	if o != nil && o.Value != nil {
		return true
	}

	return false
}

// SetValue gets a reference to the given []Application and assigns it to the Value field.
func (o *CollectionOfApplications) SetValue(v []Application) {
	o.Value = v
}

func (o CollectionOfApplications) MarshalJSON() ([]byte, error) {
	toSerialize := map[string]interface{}{}
	if o.Value != nil {
		toSerialize["value"] = o.Value
	}
	return json.Marshal(toSerialize)
}

type NullableCollectionOfApplications struct {
	value *CollectionOfApplications
	isSet bool
}

func (v NullableCollectionOfApplications) Get() *CollectionOfApplications {
	return v.value
}

func (v *NullableCollectionOfApplications) Set(val *CollectionOfApplications) {
	v.value = val
	v.isSet = true
}

func (v NullableCollectionOfApplications) IsSet() bool {
	return v.isSet
}

func (v *NullableCollectionOfApplications) Unset() {
	v.value = nil
	v.isSet = false
}

func NewNullableCollectionOfApplications(val *CollectionOfApplications) *NullableCollectionOfApplications {
	return &NullableCollectionOfApplications{value: val, isSet: true}
}

func (v NullableCollectionOfApplications) MarshalJSON() ([]byte, error) {
	return json.Marshal(v.value)
}

func (v *NullableCollectionOfApplications) UnmarshalJSON(src []byte) error {
	v.isSet = true
	return json.Unmarshal(src, &v.value)
}