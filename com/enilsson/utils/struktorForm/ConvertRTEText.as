/** 
 *	ConvertRTEText.as
 *
 *	Converts Rich Text Editor HTML tags to and back from xHTML tags
 *
 *	James Kim
 * 
 */

package com.enilsson.utils.struktorForm
{
	public class ConvertRTEText
	{
		public function ConvertRTEText()
		{
		}
		
		static public function fromXHtml(str:String):String
		{
			var pattern:RegExp;

			// Remove any carriage returns and tabs and double or more spaces
			pattern = /[\n\r\t]/g;
			str = str.replace(pattern, "");
			pattern = /( ){2,}/g;
			str = str.replace(pattern, " ");
			pattern = /&nbsp;/g;
			str = str.replace(pattern, " ");

			// Replace paragraph styles
			pattern = /<p style=\"text-align:left;margin:0\">/g;
			str = str.replace(pattern, "<P ALIGN=\"LEFT\">");
			pattern = /<p style=\"text-align:center;margin:0\">/g;
			str = str.replace(pattern, "<P ALIGN=\"CENTER\">");
			pattern = /<p style=\"text-align:right;margin:0\">/g;
			str = str.replace(pattern, "<P ALIGN=\"RIGHT\">");
			pattern = /<p style=\"text-align:justify;margin:0\">/g;
			str = str.replace(pattern, "<P ALIGN=\"JUSTIFY\">");
			pattern = /<\/p>/g;
			str = str.replace(pattern, "</P>");

			// Replace font styles
			pattern = /<span style=\"(.*?)\">/g;
			str = str.replace(pattern, "<FONT $1>");
			pattern = /color:(.*?);/g;
			str = str.replace(pattern, "COLOR=\"$1\" ");
			pattern = /font-size:(.*?)px;/g;
			str = str.replace(pattern, "SIZE=\"$1\" ");
			pattern = /font-family:(.*?);/g;
			str = str.replace(pattern, "FACE=\"$1\" ");
			pattern = /text-align:(.*?);/g;
			str = str.replace(pattern, "ALIGN=\"$1\" ");
			pattern = /<\/span.*?>/g;
			str = str.replace(pattern, "</FONT>");

			// Replace bullet points styles
			pattern= /<\/li>( )?<li>/g;
			str = str.replace(pattern, "</LI><LI>");
			pattern= /<\/li>( )?<\/ul>/g;
			str = str.replace(pattern, "</LI>");
			pattern= /<ul>( )?<li>/g;
			str = str.replace(pattern, "<LI>");

			// Replace text effects
			pattern = /<em>/g;
			str = str.replace(pattern, "<I>");
			pattern = /<\/em>/g;
			str = str.replace(pattern, "</I>");
			pattern = /<strong>/g;
			str = str.replace(pattern, "<B>");
			pattern = /<\/strong>/g;
			str = str.replace(pattern, "</B>");
			pattern = /<u>/g;
			str = str.replace(pattern, "<U>");
			pattern = /<\/u>/g;
			str = str.replace(pattern, "</U>");

			// Remove any extra white spaces
			pattern = /( ){2,}/g;
			str = str.replace(pattern," ");

			return str;
		}

		static public function toXHtml(str:String):String
		{
			var pattern:RegExp;
			
			// Remove unnecessary tags only used in flex
			pattern = /<TEXTFORMAT.*?>/g;
			str = str.replace(pattern, "");
			pattern = /<\/TEXTFORMAT.*?>/g;
			str = str.replace(pattern, "");
			pattern = /LETTERSPACING=\".*?\"/g;
			str = str.replace(pattern, "");
			pattern = /KERNING=\".*?\"/g;
			str = str.replace(pattern, "");

			// Replace paragraph tags
			pattern = /<P ([^>]+?)><FONT ([^>]+?)>( )?<\/FONT><\/P>/g; // empty paragraphs
			str = str.replace(pattern, "<P $1><FONT $2>&nbsp;</FONT></P>"); // replace with &nbsp;

			// Replace list tags
			pattern = /<LI><FONT ([^>]+?)>( )?<\/FONT><\/LI>/g; // empty lists - doesnt show bullets in flex but does in email
			str = str.replace(pattern, "<LI><FONT $1>&nbsp;</FONT></LI>"); // add space - shows bullets in flex once saved

			pattern = /<P ALIGN="LEFT">/g;
			str = str.replace(pattern, "<p style=\"text-align:left;margin:0\">");
			pattern = /<P ALIGN="CENTER">/g;
			str = str.replace(pattern, "<p style=\"text-align:center;margin:0\">");
			pattern = /<P ALIGN="RIGHT">/g;
			str = str.replace(pattern, "<p style=\"text-align:right;margin:0\">");
			pattern = /<P ALIGN="JUSTIFY">/g;
			str = str.replace(pattern, "<p style=\"text-align:justify;margin:0\">");
			pattern = /<\/P>/g;
			str = str.replace(pattern, "</p>\n");

			pattern = /<FONT [^>]+?><\/FONT>)?/g; // remove empty font tags
			str = str.replace(pattern, "");

			// Replace font styles
			pattern = /<FONT (.*?)>/g;
			str = str.replace(pattern, "<span style=\"$1\">");
			pattern = /COLOR=\"(.*?)\"/g;
			str = str.replace(pattern, "color:$1;");
			pattern = /SIZE=\"(.*?)\"/g;
			str = str.replace(pattern, "font-size:$1px;");
			pattern = /FACE=\"(.*?)\"/g;
			str = str.replace(pattern, "font-family:$1;");
			pattern = /ALIGN=\"(.*?)\"/g;
			str = str.replace(pattern, "text-align:$1;");
			pattern = /<\/FONT.*?>/g;
			str = str.replace(pattern, "</span>");

			pattern= /<\/LI><LI>/g;
			str = str.replace(pattern, "</li>\n<li>");
			pattern= /<\/LI>/g;
			str = str.replace(pattern, "</li>\n</ul>\n");
			pattern= /<LI>/g;
			str = str.replace(pattern, "<ul>\n<li>");

			// Replace text effects
			pattern = /<I>/g;
			str = str.replace(pattern, "<em>");
			pattern = /<\/I>/g;
			str = str.replace(pattern, "</em>");
			pattern = /<B>/g;
			str = str.replace(pattern, "<strong>");
			pattern = /<\/B>/g;
			str = str.replace(pattern, "</strong>");
			pattern = /<U>/g;
			str = str.replace(pattern, "<u>");
			pattern = /<\/U>/g;
			str = str.replace(pattern, "</u>");

			// Remove any extra white spaces
			pattern = /( ){2,}/g;
			str = str.replace(pattern," ");
			pattern = /\s\"/g;
			str = str.replace(pattern,"\"");

			pattern = /\&apos;/g;
			str = str.replace(pattern,"&#39;");

			return str;
       }

       static public function forceXHtmlFontFamily(str:String, font:String):String
       {
			var pattern:RegExp;
			
			// Remove unnecessary tags only used in flex
			pattern = /font-family:[^]+?;/g;
			str = str.replace(pattern, "font-family:"+font+";");
			str = str.replace(pattern , "");
			
			return str;
       }
	}
}