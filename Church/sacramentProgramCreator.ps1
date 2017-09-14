$program = Import-CSV "C:\users\Nate\Documents\Church\program.csv"
$conductor = $program.Conductor[0]
$openingHymn = $program.Hymns[0]
$sacramentHymn = $program.Hymns[1]
if($programs.Hymns.Count -eq 4){
    # Open Template with intermediate hymn
    $intermediateHymn = $program.Hymns[2]
}
else{
    # Open template with Musical Number
}
$closingHymn = $program.Hymns[3]
$invocation = $program.Prayers[0]
$benediction = $program.Prayers[1]
$speaker1 = $program.Speakers[0]
$speaker2 = $program.Speakers[1]
if($program.Speakers.Count -eq 3){
    # Open 3 Speaker Template
    $speaker3 = $program.Speakers[2]
}

$document = "C:\users\Nate\Documents\Church\Test Template2.docx"
$Word = New-Object -Com Word.Application
$Word.Visible = $true
$doc = $word.Documents.Open($document)
$doc.FormFields.Item('Date').Result = "$(Get-Date -format 'MMMM d, yyyy')"
$doc.FormFields.Item('Conducting').Result = $conductor # TODO
$doc.FormFields.Item('OpeningHymn').Result = $openingHymn # TODO
$doc.FormFields.Item('Invocation').Result = $invocation # TODO
$doc.FormFields.Item('SacramentHymn').Result = $sacramentHymn # TODO
$doc.FormFields.Item('Speaker1').Result = $speaker1 # TODO
$doc.FormFields.Item('IntermediateHymn').Result = $intermediateHymn # TODO
$doc.FormFields.Item('Speaker2').Result = $speaker2 # TODO
$doc.FormFields.Item('ClosingHymn').Result = $closingHymn # TODO
$doc.FormFields.Item('Benediction').Result = $benediction # TODO
$doc.FormFields.Item('Date2').Result = "$(Get-Date -format 'MMMM d, yyyy')"
$doc.FormFields.Item('Conducting2').Result = $conductor # TODO
$doc.FormFields.Item('OpeningHymn2').Result = $openingHymn # TODOODO
$doc.FormFields.Item('Invocation2').Result = $invocation # TODODO
$doc.FormFields.Item('SacramentHymn2').Result = $sacramentHymn # TODO # TODO
$doc.FormFields.Item('Speaker12').Result = $speaker1 # TODO
$doc.FormFields.Item('IntermediateHymn2').Result = $intermediateHymn # TODO' # TODO
$doc.FormFields.Item('Speaker22').Result = $speaker2 # TODO
$doc.FormFields.Item('ClosingHymn2').Result = $closingHymn # TODOODO
$doc.FormFields.Item('Benediction2').Result = $benediction # TODODO
$doc.FormFields.Item('Announcements1').Result = $announcements # TODODO
$doc.FormFields.Item('Announcements2').Result = $announcements # TODODO


$conductor # TODO
$openingHymn # TODO
$invocation # TODO
$sacramentHymn # TODO
$speaker1 # TODO
$intermediateHymn # TODO
$speaker2 # TODO
$closingHymn # TODO
$benediction # TODO