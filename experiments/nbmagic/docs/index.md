# nbmagic

This is a notebook (sort of)

<nb-magic autoplay controls></nb-magic>

## Javascript

```javascript
%nbmagic: {"kernel":"js"}
console.log("Hello, world!"); 

await new Promise((resolve) => setTimeout(resolve, 1000)); 

console.log("Done waiting!"); 
globalThis.name = "hackers"
```


```javascript
%nbmagic: {"kernel":"js"}
console.log(`Hello, ${globalThis.name}!`);
```

## Swipl

```prolog
%nbmagic: {"kernel":"swipl", "type":"program"}
parent_child(bob, alice).
parent_child(bob, roxy).
```

```prolog
%nbmagic: {"kernel":"swipl", "type":"query"}
parent_child(bob, C).
```