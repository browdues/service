# GopherCon 2021 - Ultimate Service


## Thoughts on project structure

#### KEY IDEA: Define policies around every layer up front. This project uses 5 layers.

**Layers > Grouping**

This is ALL about your mental model. Start with the data!

For a given layer (or sub package), make sure that sub-packages do not import each other!

When Bill starts any project, he either starts with the UI or if there is no UI start at the database itself. Start with the data! Get this part right from the jump! You cannot have a package of common data model that everything imports! Just about every package will have its own set of MODELS and DATA MARSHALLING so cascading data effects don't occur. This will allow us to easily transform between layers.

Rob Pike: *“Data dominates. If you've chosen the right data structures and organized things well, the algorithms will almost always be self-evident. Data structures, not algorithms, are central to programming.”*
#

## The Five layers
It's taken Bill 10 years to land here. It works for him. Its ***a** way* NOT ***the** way*.
### 1. **app** - "Presentation" layer - should only be accessing the core api's (business/core)

### 2. **business** - all biz logic

### 3. **foundation** - These are "foundational" in that they do not specifically solve any business problems. All business logic should use these APIs almost exclusively to solve business logic.
These packages have restrictive policies
- Not allowed to log
- Do not use logger interfaces!

### 4. **vendor** - Bill advocates owning everything until you cannot

### 5. **zarf** - This work means "a protective layer to stop you from burning your hands.". He uses it to represent all the configuration for docker, k8s, etc
- Bill advocates separating dockerfiles (even if they can be reused) in order to MAINTAIN SIMPLICITY. He doesn't mind reusing a bit of code to promote glancability. Hence this will have two dockerfiles, one for the sales-api and another for metrics.
#

KNOWLEDGE NUG: The sole purpose of the go.sum file is to validate that you're using the same code that the project used in the past. If they match, you're good. If they don't match, than you know that someone has done something fraugulent. It exists for security, durability, and for your protection.

#

