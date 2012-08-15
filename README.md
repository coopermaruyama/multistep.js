AutoValid
==========
AutoValid is a simple javascript file dependent on jQuery that allows you to create multi-step forms with validation without having to add any form of extra javascript to your files. It's extremely convenient if you make many sites with forms on it.

AutoValid automatically validates all input field types including check boxes, radios, and drop-down lists. It validates string length, emails, phone numbers, and checked box count. It allows you to set a minimum/maximum length on any input field without using javascript.

AutoValid is also nice to use because it validation each field independently on it's "onChange" event, so that the user is notified whether what they just typed into a field is valid as soon as they change its value.

How it Works
-------------
AutoValid depends on the structure of your form. It's a simple structure that looks like so (assuming you have 3 steps):
	`&lt;form id="form"&gt;
		&lt;div class="step"&gt;
			&lt;input type="text" min="5" max="35"&gt;
			&lt;button type="submit" class="submit"&gt;Continue&lt;/button&gt;
		&lt;/div&gt;
		&lt;div class="step"&gt;
			&lt;input type="text" class="phone"&gt;
			&lt;input type="text" class="email"&gt;
			&lt;button type="submit" class="submit"&gt;Continue&lt;/button&gt;
		&lt;/div&gt;
		&lt;div class="step last"&gt;
			&lt;input type="checkbox" name="checks" min="2"&gt;1
			&lt;input type="checkbox" name="checks"&gt;2
			&lt;input type="checkbox" name="checks"&gt;3
			&lt;button type="submit" class="submit"&gt;Submit&lt;/button&gt;
		&lt;/div&gt;
	&lt;/form&gt;`

The basic structure is:
- A form must have the id of "form"
- Each step must be it's immediate child with the class "step"
- The last step must have the class of "last" as well
- The submit button on each step needs the class "submit"

Options
---------
The above illustrated form has 3 steps. note that min & max attributes on the first input and the first checkbox. By setting the min attribute and max atribute on a text input, you can set the minimum length and maximum length. By setting the min attribute on the FIRST checkbox in a set of checkboxes, you can set a minimum amount of checkboxes that must be checked in order to be valid. All this, without any javascript :)

Installation
---------------
1. Download autovalid [here.](https://github.com/coopermaruyama/autovalid/zipball/master "AutoValid")
2. Copy the autovalid folder to your website directory.
3. Add AutoValid to your header like so (assuming Autovalid is in the same directory as the web page):

	&lt;script src="http://code.jquery.com/jquery-latest-min.js"&gt;&lt;/script&gt;
	&lt;script type="text/javascript" src="autovalid/autovalid.js"&gt;&lt;/script&gt;
	&lt;link rel="stylesheet" href="autovalid/autovalid.css"&gt;
4. That's it! Now create an awesome form in seconds and enjoy!

You can always look at demo.html included in the ZIP file to see an example.

Notes
----------
AutoValid is compiled from Coffeescript into Javascript. The original Coffeescript is included in the src folder within the ZIP for you to edit.

My goal with AutoValid is to make creating multi-step forms easy and simple. I realize that I could have created a plugin and call validation like $('#element').autoValid() but I like the idea of zero javascript knowledge required to use this. If you'd like this to be a plugin let me know and I'll create it or you can fork it yourself.