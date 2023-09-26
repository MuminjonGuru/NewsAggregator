unit NewsAggregator.UnitMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Layouts, FMX.Objects, FMX.Memo.Types,
  FMX.ScrollBox, FMX.Memo, REST.Types, REST.Client, Data.Bind.Components,
  Data.Bind.ObjectScope, System.Net.URLClient, System.Net.HttpClient,
  System.Net.HttpClientComponent;

type
  TFormMain = class(TForm)
    ToolBarMain: TToolBar;
    LblCaption: TLabel;
    ScrollBoxMain: TScrollBox;
    Rectangle1: TRectangle;
    Image1: TImage;
    Memo1: TMemo;
    Button1: TButton;
    BtnGetNews: TButton;
    RESTClient1: TRESTClient;
    RESTRequest1: TRESTRequest;
    RESTResponse1: TRESTResponse;
    RESTRequest2: TRESTRequest;
    RESTResponse2: TRESTResponse;
    RESTClient2: TRESTClient;
    procedure Button1Click(Sender: TObject);
    procedure BtnGetNewsClick(Sender: TObject);
  private
    { Private declarations }
    FUrl: String;
  public
    { Public declarations }
  end;

var
  FormMain: TFormMain;

implementation

{$R *.fmx}

uses
  System.JSON;

procedure TFormMain.BtnGetNewsClick(Sender: TObject);
begin
  // fetch news here
  RESTClient1.ResetToDefaults;
  RESTClient1.Accept := 'application/json';
  RESTClient1.AcceptCharset := 'UTF-8, *;q=0.8';
  RESTClient1.BaseURL :=
    Format('http://api.mediastack.com/v1/news?access_key=%s&limit=1&countries=us',
    ['6a471d4d8e2df064e39580d6d25ec502']);

  // send API endpoint request
  RESTRequest1.Execute;

  // parse the country code from the response
  try
    var JSONValue := TJSONObject.ParseJSONValue(RESTResponse1.Content);
    var JSONArray := JSONValue.GetValue<TJSONArray>('data');
    var ArrayElement: TJSONValue;

    for ArrayElement in JSONArray do
    begin
      Memo1.Lines.Append('Title: ' + ArrayElement.GetValue<String>('title'));
      Memo1.Lines.Append('Description: ' + ArrayElement.GetValue<String>
        ('description'));
      Memo1.Lines.Append('Source: ' + ArrayElement.GetValue<String>
        ('source'));
      Memo1.Lines.Append('Full News here: ' + ArrayElement.GetValue<String>
        ('url'));
      FUrl := ArrayElement.GetValue<String>('url');

      // load images to the newly created TImage component
      var MemoryStream := TMemoryStream.Create;
      var HTTPClient := TNetHTTPClient.Create(nil);
      var HTTPRequest := TNetHTTPRequest.Create(nil);

      HTTPRequest.Client := HTTPClient;
      try
        var
        ImageURL := ArrayElement.GetValue<String>('image');
        HTTPRequest.Get(ImageURL, MemoryStream);
        MemoryStream.Seek(0, soFromBeginning);
        Image1.Bitmap.LoadFromStream(MemoryStream);
      finally
        FreeAndNil(MemoryStream);
        FreeAndNil(HTTPClient);
        FreeAndNil(HTTPRequest);
      end;

    end;
  finally

  end;

end;

procedure TFormMain.Button1Click(Sender: TObject);
begin
  // get the full page into PDF
  RESTClient2.ResetToDefaults;
  RESTClient2.Accept := 'application/json';
  RESTClient2.AcceptCharset := 'UTF-8, *;q=0.8';
  RESTClient2.BaseURL :=
    Format('https://api.apilayer.com/url_to_pdf?apikey=%s&url=%s&print=true',
    ['QdSe87VnIPlTkpLrS5i46iVl8XJqlDlf', FUrl]);

  // send API endpoint request
  RESTRequest2.Execute;

  var JSONValue := TJSONObject.ParseJSONValue(RESTResponse2.Content);
  try
    if JSONValue is TJSONObject then
    begin
      FUrl := JSONValue.GetValue<String>('pdf_url');
    end;
  finally
    JSONValue.Free;
  end;

  // load the image
  var HTTPClientDownloadPDF := TNetHTTPClient.Create(nil);
  var HTTPRequestDownloadPDF := TNetHTTPRequest.Create(nil);

  var FileStream := TFileStream.Create('news.pdf', fmCreate);

  HTTPRequestDownloadPDF.Client := HTTPClientDownloadPDF;
  try
    HTTPRequestDownloadPDF.Get(FUrl, FileStream);

    finally
      FreeAndNil(FileStream);
      FreeAndNil(HTTPRequestDownloadPDF);
      FreeAndNil(HTTPRequestDownloadPDF);
    end;
end;

end.
