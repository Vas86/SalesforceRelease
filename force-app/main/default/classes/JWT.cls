/*************************** 
* @Name          JWT.cls
* @Author        vasu@driva.com.au
* @Date          29/04/2022
* @description   Handles JWT Token logic
******************************************************
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-----------------------------------------------------------------------
*  1.0              Vasu      29/04/2022          Modified adding signService() for service-layer
****************************** */
public class JWT{
    public static String base64URLencode(Blob input){ 
        String output = encodingUtil.base64Encode(input);
        output = output.replace('+', '-');
        output = output.replace('/', '_');
        while ( output.endsWith('=')){
            output = output.subString(0,output.length()-1);
        }
        return output;
    }
   
     public static String sign() {      
        String header = '{"alg": "HS256","typ":"JWT"}';
        DateTime now = DateTime.now();
        String exp = String.valueof(now.addMinutes(3).getTime()/1000);
        String payload = '{"name":"driva", "exp":'+exp+'}';
        string jwt = base64URLencode(blob.valueof(header)) + '.' +base64URLencode(blob.valueof(payload));
        
        Blob key = blob.valueof('dBy6OwUdxzSDSTpEOx2uw3ZjF3Gc6Ogg');
        blob signature = Crypto.generateMac('hmacSHA256',Blob.valueof(jwt),key);
        
        String result = jwt + '.' + base64URLencode(signature);
        return result;
    }
/* sign for service-layer*/
public static String signService() {      
    String header = '{"alg": "HS256","typ":"JWT"}';
    DateTime now = DateTime.now();
    String exp = String.valueof(now.addMinutes(3).getTime()/1000);
    String payload = '{"name":"driva", "exp":'+exp+'}';
    string jwt = base64URLencode(blob.valueof(header)) + '.' +base64URLencode(blob.valueof(payload));
   
    Blob key = blob.valueof(System.Label.JWTKey);
    blob signature = Crypto.generateMac('hmacSHA256',Blob.valueof(jwt),key);
   
    String result = jwt + '.' + base64URLencode(signature);
    return result;
}
   

}