---
layout: post
title: Objective-j - extending javascript.
categories: [research, framework, language]
---

[http://www.cappuccino-project.org/learn/objective-j.html](http://www.cappuccino-project.org/learn/objective-j.html)

Objective-j is an object oriented language built on top of Javascript. It is provided via the Cappuccino framework. Some of it's features are 
explained below.

### Classes

Classes are introduced in the following way. The class is everything between the implimentation and end.

```
@implementation Person : CPObject 
{

}
@end
```

### Methods

```
- (void)setName:(CPString)aName
{
    name = aName;
}
```

The - means the method is private. + makes it public.

(void) is the return type, this can be any type or object.

(CPString)aName is a parameter, with type and name of the variable. With more than one parameter a colon seperator is used:

```
- (void)setJobTitle:(CPString)aJobTitle company:(CPString)aCompany
```
