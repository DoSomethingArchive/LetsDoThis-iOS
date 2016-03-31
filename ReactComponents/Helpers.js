module.exports = {
  /**
   * Formats date string to be use for news feed posts.
   *
   * @param date Unformatted date string
   * @return string
   */
  formatDate: function(date) {
    // @todo Will need a different way to handle this when multi-language
    // support comes around.
    var months = ['January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'];
    
    // Fun fact: the API sends the date in the format "yyyy-MM-dd hh:mm:ss"
    // This is fine with V8, but JavaScriptCore which iOS/Safari uses does
    // not like it. Reformatting the string by adding a 'T' in place of the
    // space makes it work for both.
    var space = date.indexOf(' ');
    if (space >= 0) {
      date = date.substring(0, space) + 'T' + date.substring(space + 1);
    }
    var d = new Date(date);
    var day = d.getDate();

    var daySuffix = 'th';
    if (day === 1 || day === 21 || day === 31) {
      daySuffix = 'st';
    }
    else if (day === 3 || day === 23) {
      daySuffix = 'rd';
    }

    return months[d.getMonth()] + ' ' + d.getDate() + daySuffix + ', ' + d.getFullYear();
  },
  /**
   * Convert unicode character codes to their human-readable characters.
   *
   * @param raw String to convert
   * @result string
   */
  convertUnicode: function(raw) {
    const regex = /&#[0-9]*;/g;
    var result = raw;
    var match;
    var matches = [];
    var i = -1;

    while ((match = regex.exec(raw)) !== null) {
      i++;
      matches[i] = match;
    }

    if (matches.length > 0) {
      // Reverse the array to work from the back of the raw string to the front
      matches.reverse();

      for (i = 0; i < matches.length; i++) {
        // First item in the match array is the unicode value
        let unicode = matches[i][0];

        // Extract the code, removing the leading `&#` and trailing `;`
        let code = unicode.substring(2, unicode.length - 1);

        // Convert to human readable character
        let character = String.fromCharCode(parseInt(code, 10));

        // Insert `character` in place of the unicode string
        let before = result.substring(0, matches[i].index);
        let after = result.substring(matches[i].index + unicode.length);
        result = before + character + after;
      }
    }

    return result;
  },
  reportbackItemExistsForSignup: function(signup) {
    if (signup.reportback 
      && signup.reportback.reportback_items 
      && signup.reportback.reportback_items.data 
      && signup.reportback.reportback_items.data[0] 
      && signup.reportback.reportback_items.data[0].id) {
      return true;
    }
    return false;
  },
  /**
   * Sanitze given first name: if it contains an email address, return "Doer".
   *
   * @param raw String to sanitize
   * @result string
   */
  sanitizeFirstName: function(firstName) {
    //  Courtesy of http://stackoverflow.com/a/16424756/1470725
    var emailRegEx = /(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))/;
    if (emailRegEx.test(firstName)) {
      return 'Doer';
    }
    return firstName;
  }
}
