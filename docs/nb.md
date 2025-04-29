# Hello world

This is a notebook (sort of)

<nb-magic autoplay controls></nb-magic>

## test

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

