AutoValid
==========
AutoValid is a **simple** jQuery plugin which allows you to create **sliding multi-step forms with validation**. It's different from other validators because almost all the customization is done in html rather than by setting plugin options. It has cool features like a *progress bar*, *back button* to navigate steps, and *styling* that lets the user know whether their entry is valid while typing.

AutoValid automatically validates all input field types including checkboxes, radios, and drop-down lists. It validates string length, emails, phone numbers, and checked box count. It allows you to set a minimum/maximum length on any input field without using javascript.

AutoValid is also nice to use because it validates each field independently on it's 'change' and 'keyup' event, so that the user is notified whether what they just typed into a field is valid as soon as they change its value.

See a Demo: [jsFiddle](http://jsfiddle.net/gh/get/jquery/1.7.2/coopermaruyama/autovalid.js/tree/master/Demo/ "AutoValid Demo")

Features
-------------
- Automatically appends a 'back' button to each step (except step 1). No markup required!
- Automatically adds a green 'tick' next to each valid field while you type (or 'error' icon if invalid)
- By default, every input field is validated. see how to set a field optional below.
- Set max and min lengths on any text input or checkbox (see below).
- Includes a progress bar
- Checks for hidden elements and bypasses them (good form forms where choosing a certain value hides/shows another input field).

How it Works
-------------
AutoValid depends on the structure of your form. It's a simple structure that looks like so (assuming you have 3 steps):

   ```html
	<form id="form">
		<div class="progress-bar"><div class="progress"></div></div>
		<div class="step">
			<input type="text" min="5" max="35">
			<select>
				<option value="">Select One..</option>
				<option value="yes">Yes</option>
				<option valud="no">No</option>
			<button type="submit" class="submit">Continue</button>
		</div>  
		<div class="step">  
			<input type="text" optional="yes">
			<input type="text" class="phone">  
			<input type="text" class="email">  
			<button type="submit" class="submit">Continue</button>  
		</div>  
		<div class="step" id="last-step">  
			<input type="checkbox" name="checks" min="2">1  
			<input type="checkbox" name="checks">2  
			<input type="checkbox" name="checks">3  
			<button type="submit" class="submit">Submit</button>  
		</div>  
	</form>
   ```

The basic structure is:
- A form must have the id of "form"
- Each step must be the form's child with the class of "step"
- The last step must have the id of "last-step" as well
- The submit button on each step needs the class "submit"

Options
---------
The above illustrated form has 3 steps. note that min & max attributes on the first input and the first checkbox. 
- By setting `optional="yes"` on any text input, you make it optional and therefore bypass validation.
- By setting the min attribute and max atribute on a text input, you can set the minimum length and maximum length. 
- By setting the min attribute on the FIRST checkbox in a set of checkboxes, you can set a minimum amount of checkboxes that must be checked in order to be valid. 
- By setting the value of an option in a select list to "" (as seen above for 'Select One'), you identify which option is invalid.

Installation
---------------
1. Download autovalid [here.](https://github.com/coopermaruyama/autovalid/zipball/master "AutoValid")
2. Copy the autovalid folder to your website directory.
3. Add AutoValid to your header like so (assuming Autovalid is in the same directory as the web page):

	 ```html
	 <script src="http://code.jquery.com/jquery-latest-min.js"></script>  
	 <script type="text/javascript" src="autovalid/autovalid.js"></script>  
	 <link rel="stylesheet" href="autovalid/autovalid.css">

	 <script type="text/javascript">
	 	$(function() {
	 	  $('#form').autoValid();
	    });
	 ```
4. That's it! Now create an awesome form in seconds and enjoy!

You can always look at demo.html included in the ZIP file to see an example.

Notes
----------
AutoValid is compiled from Coffeescript into Javascript. The original Coffeescript is included in the src folder within the ZIP for you to edit.

My goal with AutoValid is to make creating multi-step forms easy and simple. I realize that I could have created a plugin and call validation like $('#element').autoValid() but I like the idea of zero javascript knowledge required to use this. If you'd like this to be a plugin let me know and I'll create it or you can fork it yourself.