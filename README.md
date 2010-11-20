# JS3 - An insane integration of RDF in ECMAScript-262 V5 (Javascript) #

In short, with this library, all your javascript is also RDF, there are no special types or classes,
each variable and value is also an RDF Node, List or Graph.

All values are both the standard javascript values you expect (no extension or suchlike), and are the RDF types you expect

## Example ##

This library doesn't inspect objects and then generate RDF, rather each value *is* RDF, and javascript:

    true.toNT();         // "true"^^<http://www.w3.org/2001/XMLSchema#boolean>
    (12 * 1.4).toNT();   // "12.3"^^<http://www.w3.org/2001/XMLSchema#decimal>
    
Here's a complicated yet simple example to illustrate, this is just a standard Object in js:

    var me = {
      a: 'foaf:Person',                                         // a String, a CURIE and a full IRI
      name: 'Nathan',                                           // a String, and an RDF Plain Literal
      age: new Date().getFullYear() - 1981,                     // a Number, and a Typed Literal with the type xsd:integer
      homepage: 'http://webr3.org',                             // a String, and an IRI, 
      holdsAccount: {                                           // an Object, with a BlankNode reference for the .id
        label: "Nathan's twitter account".l('en'),              // a String, and a Literal with a .language
        accountName: 'webr3',                                   // noticed that you don't need the prefixes yet?
        accountProfilePage: 'http://twitter.com/webr3'          
      },
      knows: bob,                                               // works with variables too of course
      nick: ['webr3','nath']                                    // an Array, also a list of values, like in turtle and n3
    }.ref(":me");                                               // still an Object, but also has a .id now, it's subject is set.

If we now call *me.n3()* we'll get the following output:

    <http://webr3.org/nathan#me> rdf:type foaf:Person;
      foaf:name "Nathan";
      foaf:age 29;
      foaf:homepage <http://webr3.org>;
      foaf:holdsAccount [
        rdfs:label "Nathan's twitter account"@en;
        foaf:accountName "webr3";
        accountProfilePage <http://twitter.com/webr3> ];
      foaf:knows <http://example.com/bob#me>;
      foaf:nick "webr3", "nath" .

It's just that simple, your javascript is your RDF, it's just plain old javascript:

    me.gender = "male";                   // .gender will resolve to foaf:gender to http://xmlns.com/foaf/0.1/gender 
    if(me.age > 18) return true;          // it's all native values, just use like normal!

### Implementation Notice ###

This library requires ECMAScript-262 V5, specifically it makes heavy usage of Object.defineProperties.

You can check the [compatibility chart](http://kangax.github.com/es5-compat-table/) to see if your platform / browser supports it.
The short version is that chrome 5+, ff4, webkit (safari) and ie9 all support this script, and on the server side node.js, rhino and besen are all fine.

Objects and values are not modified in the usual manner and they are not converted in to different types, rather this library automagically redefines
the property descriptors on objects to allow each value to be both a native javascript value, and an RDF compatible value.

## Nodes & Values ##

All values of type string, number, boolean and date are also RDF Nodes, and are fully aligned (and compatible) with the Interfaces
from the RDFa API.

### Standard Methods ####
All of the basic js types (string, number, boolean and date) are augmented with the following methods:

*   **.nodeType()** - returns one of PlainLiteral, TypedLiteral, BlankNode or IRI
    
        true.nodeType();                  // TypedLiteral
        (12 * 1.4).nodeType();            // TypedLiteral
        new Date().nodeType();            // TypedLiteral
        "hello world".nodeType();         // PlainLiteral
        "_:b12".nodeType();               // BlankNode
        "foaf:name".nodeType();           // IRI
        "http://webr3.org/".nodeType();   // IRI
    
*   **.equals(other)** - returns boolean

    RDF type safe equality test.
    
        "hello" == "hello".l('en')        // true
        "hello".equals( "hello".l('en') ) // false

*   **.toNT()** - returns string

    Does what it says on the tin, returns the N-Triples formatted value.
    
        true.toNT();                      // "true"^^<http://www.w3.org/2001/XMLSchema#boolean>
        (12 * 1.4).toNT();                // "12.3"^^<http://www.w3.org/2001/XMLSchema#decimal>
        new Date().toNT();                // "2010-11-20T21:06:42Z"^^<http://www.w3.org/2001/XMLSchema#dateTime>
        "hello world".toNT();             // "hello world"
        "hello world".l('en').toNT();     // "hello world"@en
        "_:b12".toNT();                   // _:b12
        "foaf:name".toNT();               // <http://xmlns.com/foaf/0.1/name>
        "http://webr3.org/".toNT();       // <http://webr3.org/>  

*   **.toCanonical()**

    Alias of .toNT(), RDFa API compatibility method.

*   **.n3()** returns string

    Returns the value formatted for N3/Turtle.

        true.n3();                        // true
        (12 * 1.4).n3();                  // 12.3
        new Date().n3();                  // "2010-11-20T21:06:42Z"^^<http://www.w3.org/2001/XMLSchema#dateTime>
        "hello world".n3();               // "hello world"
        "hello world".l('en').n3();       // "hello world"@en
        "_:b12".n3();                     // _:b12
        "foaf:name".n3();                 // foaf:name
        "http://webr3.org/".n3();         // <http://webr3.org/> 


### String Methods ####
A string can represent any of the RDF Node types, PlainLiteral (+language), TypedLiteral, BlankNode or IRI.
In js3 string exposes the following methods (in addition to the standard methods outlined above):

*   **.l()** - returns this

    Set the language of a PlainLiteral - exposes the **.language** attribute after calling. (.language is non-enumerable, read-only)

        var s = "Hello World".l('en');                        
        s.language                        // 'en'
        s.nodeType();                     // PlainLiteral
        s.toNT();                         // "Hello World"@en
 
*   **.tl()** - returns this

    Set the type of a TypedLiteral - exposes the **.type** attribute after calling. (.type is non-enumerable, read-only)

        var s = "0FB7".tl('xsd:hexBinary');
        s.type                            // http://www.w3.org/2001/XMLSchema#hexBinary
        s.nodeType();                     // TypedLiteral
        s.toNT();                         // "0FB7"^^<http://www.w3.org/2001/XMLSchema#hexBinary>
        
    Note: this method also caters for the situations when you want a PlainLiteral to be an xsd:string, or an IRI to be a PlainLiteral
    
        var u = "http://webr3.org/";      // <http://webr3.org/>
        u.tl("rdf:PlainLiteral);          // "http://webr3.org/"
        
        var h = "hello";                  // "hello"
        "hello".tl('xsd:string');         // "hello"^^<http://www.w3.org/2001/XMLSchema#string>
 
*   **.resolve()** - returns string IRI

    Resolve a CURIE to a full IRI - note this is done automatically by .n3 and .toNT methods.

        "foaf:name".resolve()             // returns string "http://xmlns.com/foaf/0.1/name" with nodeType IRI

Remember, all javascript values and types remain unchanged, so it's entirely backwards compatible with all existing data, and will not modify any js values,
"Hello World".l('en') is still a String, properties like .language and .type are non-enumerable, so they won't show up in for loops or when you JSON.stringify
the values. You cannot implement this library in non v5 ecmascript by simply adding a .language property to the String object, that simply won't work.

### Numbers ####

js3 is fully aware of number types, it knows when a number is an integer, a double or a decimal.

    12 .toNT()                            // "12"^^<http://www.w3.org/2001/XMLSchema#integer>
    12.1 .toNT()                          // "12.1"^^<http://www.w3.org/2001/XMLSchema#decimal>
    1267.43233E32 .toNT()                 // "1.26743233e+35"^^<http://www.w3.org/2001/XMLSchema#double>

**Gotcha:** do note that you need to add a space between the number and the .method, or wrap the number in braces *(12.1).toNT()*,
since js expects any integer followed immediately by a period to be a decimal, like 12.145 - this only applies to hard coded in the source-code numbers, and not
those in variables or returned from functions, so generally isn't noticable, in the same way that you don't normally write 12.toString()!


## Arrays and Lists ##

JS3 uses arrays for both lists of objects in property-object chains { name: ['nathan','nath'] } and as rdf Lists.

You can determine whether an array is a list or not by inspecting the boolean property **.list** on any array. To specify that an array is a list you simply call .toList() on it.

### Array Methods and Properties

*   **.list** - boolean

    Boolean flag indicating whether an array is an RDF list. 
    
*   **.toList()** - returns this

    Specifies that an array is to be used as an RDF list, sets the .list property to true.

*   **.n3()** returns string

    Returns the value formatted for N3/Turtle.

        [1,2,3,4].n3()                        // 1, 2, 3, 4
        [1,2,3,4].toList().n3()               // ( 1 2 3 4 )
        
Note that there are no .toNT or .nodeType methods, or related, arrays and lists are not RDF Nodes.

## Objects and Descriptions ##

In js3 each Object is by default just an Object with a single addition method exposed **.ref()**. When you call this method the object is RDF enabled,
whereby it is set to denote the description of something - identified by a blanknode or an IRI - the keys (properties) are mapped to RDF Properties,
a **.id** attribute is exposed on the object, and four methods are also exposed: **.n3()**, **.toNT()**, **.using()** and **.graphify()**.