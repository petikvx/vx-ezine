// encryptionDlg.cpp : implementation file
//

#include "stdafx.h"
#include "encryption.h"
#include "encryptionDlg.h"

/*

This small app creates the auth key for regabot.
just insert the text to encrypt into the specific field, press encrpyt.
copy/past encrypted data to your IRC client and write it to the bots.

Example:
--------
Your DNS or IP: RadiatioN@radiation.users.undernet.org
(you get DNS or Ip when you write .dns in query to one of the bots)

Enter this to encrypt: RadiatioNradiation.users.undernet.org

enter result as here in IRC client: .auth Xknsk~suTxknsk~sut8q?4yoxy4tnoxto~4uxm

and now are you authed with all bots in the channel :)

No Copyright - free for any use

Written by RadiatioN in March-July 2006

Zine and group site:
EOF - Electrical Ordered Freedom
http://www.eof-project.net

My site:
RadiatioN's VX World
http://radiation.eof-project.net

Contact:
radiation[at]eof-project[dot]net

some nice greetings to Sky my good friend :)

*/

#ifdef _DEBUG
#define new DEBUG_NEW
#endif

// CencryptionDlg dialog

char * EncryptString(char *szString, int iShift, int iKey)
{
	int iLen=strlen(szString);

	for(int i=0; i<iLen; i++)
	{
		szString[i]+=iShift;
		szString[i]=szString[i]^iKey;
		szString[i]+=iShift;
	}

	return szString;
}

char * DecryptString(char *szString, int iShift, int iKey)
{
	int iLen=strlen(szString);

	for(int i=0; i<iLen; i++)
	{
		szString[i]-=iShift;
		szString[i]=szString[i]^iKey;
		szString[i]-=iShift;		
	}

	return szString;
}


CencryptionDlg::CencryptionDlg(CWnd* pParent /*=NULL*/)
	: CDialog(CencryptionDlg::IDD, pParent)
	, szEncrypt(_T(""))
	, szDecrypt(_T(""))
	, iKey(2)
	, iShift(4)
{
	m_hIcon = AfxGetApp()->LoadIcon(IDR_MAINFRAME);
}

void CencryptionDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	DDX_Text(pDX, IDC_EDIT2, szEncrypt);
	DDX_Text(pDX, IDC_EDIT1, szDecrypt);
	DDX_Text(pDX, IDC_EDIT3, iKey);
	DDX_Text(pDX, IDC_EDIT4, iShift);
}

BEGIN_MESSAGE_MAP(CencryptionDlg, CDialog)
	ON_WM_PAINT()
	ON_WM_QUERYDRAGICON()
	//}}AFX_MSG_MAP
	ON_BN_CLICKED(IDOK2, &CencryptionDlg::OnBnClickedOk2)
	ON_BN_CLICKED(IDOK, &CencryptionDlg::OnBnClickedOk)
	ON_BN_CLICKED(IDOK3, &CencryptionDlg::OnBnClickedOk3)
	ON_BN_CLICKED(IDOK4, &CencryptionDlg::OnBnClickedOk4)
END_MESSAGE_MAP()


// CencryptionDlg message handlers

BOOL CencryptionDlg::OnInitDialog()
{
	CDialog::OnInitDialog();

	// Set the icon for this dialog.  The framework does this automatically
	//  when the application's main window is not a dialog
	SetIcon(m_hIcon, TRUE);			// Set big icon
	SetIcon(m_hIcon, FALSE);		// Set small icon

	// TODO: Add extra initialization here

	return TRUE;  // return TRUE  unless you set the focus to a control
}

// If you add a minimize button to your dialog, you will need the code below
//  to draw the icon.  For MFC applications using the document/view model,
//  this is automatically done for you by the framework.

void CencryptionDlg::OnPaint()
{
	if (IsIconic())
	{
		CPaintDC dc(this); // device context for painting

		SendMessage(WM_ICONERASEBKGND, reinterpret_cast<WPARAM>(dc.GetSafeHdc()), 0);

		// Center icon in client rectangle
		int cxIcon = GetSystemMetrics(SM_CXICON);
		int cyIcon = GetSystemMetrics(SM_CYICON);
		CRect rect;
		GetClientRect(&rect);
		int x = (rect.Width() - cxIcon + 1) / 2;
		int y = (rect.Height() - cyIcon + 1) / 2;

		// Draw the icon
		dc.DrawIcon(x, y, m_hIcon);
	}
	else
	{
		CDialog::OnPaint();
	}
}

// The system calls this function to obtain the cursor to display while the user drags
//  the minimized window.
HCURSOR CencryptionDlg::OnQueryDragIcon()
{
	return static_cast<HCURSOR>(m_hIcon);
}


void CencryptionDlg::OnBnClickedOk2()
{
	// TODO: Add your control notification handler code here
	char szTemp[200]="";

	UpdateData(true);

	strcpy(szTemp, szEncrypt);

	szDecrypt.SetString(EncryptString(szTemp, iShift, iKey));
	UpdateData(false);
}

void CencryptionDlg::OnBnClickedOk()
{
	// TODO: Add your control notification handler code here
	PostQuitMessage(0);
}

void CencryptionDlg::OnBnClickedOk3()
{
	// TODO: Add your control notification handler code here
	char szTemp[200]="";

	UpdateData(true);

	strcpy(szTemp, szDecrypt);

	szEncrypt.SetString(DecryptString(szTemp, iShift, iKey));
	UpdateData(false);
}

void CencryptionDlg::OnBnClickedOk4()
{
	// TODO: Add your control notification handler code here
	srand(GetTickCount());
	
	iKey = (rand()%25) + 1;
	iShift = (rand()%25) + 1;
	UpdateData(false);
}
