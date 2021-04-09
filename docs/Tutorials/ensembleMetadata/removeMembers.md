# Remove metadata for specific ensemble members
Sometimes, you might manipulate a state vector ensemble to remove some of the ensemble members. When you do sop, you may want to update the ensembleMetadata object to reflect the reduced ensemble. You can use the "removeMembers" method to remove the metadata for the deleted ensemble members. Here the syntax is:
```matlab
ensMeta2 = ensMeta.removeMembers(members)
```
Here, "members" is either a vector of linear indices, or a logical vector with one element per ensemble member. The output "ensMeta2" is the updated ensembleMetadata object for the reduced ensemble.

For example, say I have an ensembleMetadata object for a state vector with 75 ensemble members. If I do:
```matlab
members = 1:5
ensMeta2 = ensMeta.removeMembers(members)
```
then ensMeta2 will manage metadata for an ensemble that only contains ensemble members 6 through 75.
